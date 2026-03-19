;; ============================================================
;; Weighted Privilege Escalator (WPE)
;; ============================================================
;; A weighted reputation-based privilege escalation system.
;;
;; Features:
;; - Weighted score accumulation
;; - Automatic tier escalation
;; - Automatic downgrade enforcement
;; - Admin threshold configuration
;; - Transparent privilege inspection
;; ============================================================

;; ========================
;; Error Codes
;; ========================

(define-constant err-unauthorized (err u100))
(define-constant err-invalid-weight (err u101))
(define-constant err-user-not-found (err u102))
(define-constant err-invalid-tier (err u103))

;; ========================
;; Contract Owner
;; ========================

(define-data-var contract-owner principal tx-sender)

;; ========================
;; Tier Thresholds
;; ========================

;; Tier thresholds define minimum score required
(define-data-var tier1-threshold uint u100)
(define-data-var tier2-threshold uint u300)
(define-data-var tier3-threshold uint u700)
(define-data-var tier4-threshold uint u1500)

;; ========================
;; Data Maps
;; ========================

(define-map users
  { user: principal }
  {
    base-score: uint,
    weight-multiplier: uint,
    weighted-score: uint,
    tier: uint
  }
)

;; ========================
;; Internal Utilities
;; ========================

(define-private (is-owner (caller principal))
  (is-eq caller (var-get contract-owner))
)

(define-private (calculate-weighted (base uint) (weight uint))
  (/ (* base weight) u100)
)

(define-private (determine-tier-helper (score uint) (t1 uint) (t2 uint) (t3 uint) (t4 uint))
  (if (>= score t4)
    u4
    (if (>= score t3)
      u3
      (if (>= score t2)
        u2
        (if (>= score t1)
          u1
          u0)))))

;; ========================
;; Admin Configuration
;; ========================

(define-public (set-tier-thresholds
    (t1 uint)
    (t2 uint)
    (t3 uint)
    (t4 uint)
  )
  (begin
    (asserts! (is-owner tx-sender) err-unauthorized)
    (asserts! (and (< t1 t2) (< t2 t3) (< t3 t4)) err-invalid-tier)

    (var-set tier1-threshold t1)
    (var-set tier2-threshold t2)
    (var-set tier3-threshold t3)
    (var-set tier4-threshold t4)

    (ok true)
  )
)

;; ========================
;; User Registration
;; ========================

(define-public (register-user (initial-weight uint))
  (let
    (
      (existing (map-get? users { user: tx-sender }))
    )

    (asserts! (is-none existing) err-unauthorized)
    (asserts! (> initial-weight u0) err-invalid-weight)

    (map-set users
      { user: tx-sender }
      {
        base-score: u0,
        weight-multiplier: initial-weight,
        weighted-score: u0,
        tier: u0
      }
    )

    (ok true)
  )
)

;; ========================
;; Score Accumulation
;; ========================

(define-public (add-score (amount uint))
  (match (map-get? users { user: tx-sender })
    user-data
    (let
      (
        (current-base (get base-score user-data))
        (weight (get weight-multiplier user-data))
        (new-base (+ current-base amount))
        (weighted (/ (* new-base weight) u100))
        (tier-val (if (>= weighted (var-get tier4-threshold)) u4 (if (>= weighted (var-get tier3-threshold)) u3 (if (>= weighted (var-get tier2-threshold)) u2 (if (>= weighted (var-get tier1-threshold)) u1 u0)))))
      )
      (begin
        (map-set users
          { user: tx-sender }
          {
            base-score: new-base,
            weight-multiplier: weight,
            weighted-score: weighted,
            tier: tier-val
          }
        )
        (ok tier-val)
      )
    )
    err-user-not-found
  )
)

;; ========================
;; Admin Weight Adjustment
;; ========================

(define-public (set-user-weight (user principal) (new-weight uint))
  (begin
    (asserts! (is-owner tx-sender) err-unauthorized)
    (asserts! (> new-weight u0) err-invalid-weight)
    
    (match (map-get? users { user: user })
      user-data
      (let
        (
          (base-score-val (get base-score user-data))
          (weighted-calc-val (/ (* base-score-val new-weight) u100))
          (t1 (var-get tier1-threshold))
          (t2 (var-get tier2-threshold))
          (t3 (var-get tier3-threshold))
          (t4 (var-get tier4-threshold))
          (is-t4 (>= weighted-calc-val t4))
          (is-t3 (>= weighted-calc-val t3))
          (is-t2 (>= weighted-calc-val t2))
          (is-t1 (>= weighted-calc-val t1))
          (new-tier-val (if is-t4 u4 (if is-t3 u3 (if is-t2 u2 (if is-t1 u1 u0)))))
        )
        (begin
          (map-set users { user: user } { base-score: base-score-val, weight-multiplier: new-weight, weighted-score: weighted-calc-val, tier: new-tier-val })
          (ok new-tier-val)
        )
      )
      err-user-not-found
    )
  )
)

;; ========================
;; Tier Inspection
;; ========================

(define-read-only (get-user (user principal))
  (map-get? users { user: user })
)

(define-read-only (get-user-tier (user principal))
  (match (map-get? users { user: user })
    data (get tier data)
    u0
  )
)

(define-read-only (get-user-weighted-score (user principal))
  (match (map-get? users { user: user })
    data (get weighted-score data)
    u0
  )
)

(define-read-only (get-thresholds)
  {
    tier1: (var-get tier1-threshold),
    tier2: (var-get tier2-threshold),
    tier3: (var-get tier3-threshold),
    tier4: (var-get tier4-threshold)
  }
)
