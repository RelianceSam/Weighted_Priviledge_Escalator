```markdown
# Weighted Privilege Escalator (WPE)

## Overview
The Weighted Privilege Escalator (WPE) is a smart contract system designed to manage user privileges based on a weighted reputation scoring mechanism. Users accumulate weighted scores through activity, which determines their privilege tier. The system automatically escalates or downgrades user tiers according to configurable thresholds.

WPE provides transparent privilege inspection, admin-controlled configuration, and ensures a fair and deterministic reputation-based access system.

---

## Features
- Weighted score accumulation based on user activity  
- Automatic tier escalation and downgrade enforcement  
- Admin-configurable thresholds for privilege tiers  
- Transparent inspection of user scores and tiers  
- Secure registration and weight management  

---

## Error Codes
| Code | Description |
|------|-------------|
| u100 | Unauthorized action |
| u101 | Invalid weight provided |
| u102 | User not found |
| u103 | Invalid tier configuration |

---

## Contract Owner
- The deployer of the contract is assigned as the `contract-owner`  
- Only the owner can update tier thresholds and adjust user weights  

---

## Tier Thresholds
- Tier thresholds define the minimum weighted score required for each tier:  
  - Tier 1: `tier1-threshold` (default: 100)  
  - Tier 2: `tier2-threshold` (default: 300)  
  - Tier 3: `tier3-threshold` (default: 700)  
  - Tier 4: `tier4-threshold` (default: 1500)  

---

## Data Storage

#### `users` Map
Each registered user has a data structure containing:
| Field | Description |
|-------|-------------|
| base-score | Total raw score accumulated |
| weight-multiplier | User-specific weight applied to scores |
| weighted-score | Weighted score used for tier calculation |
| tier | Current privilege tier (u0–u4) |

---

## Core Functions

### Admin Functions
- **`set-tier-thresholds(t1, t2, t3, t4)`**: Update thresholds for all tiers.  
- **`set-user-weight(user, new-weight)`**: Adjust a user's weight multiplier.

### User Functions
- **`register-user(initial-weight)`**: Registers a new user with an initial weight multiplier.  
- **`add-score(amount)`**: Adds activity points to the user’s base score and updates the weighted score and tier accordingly.

### Read-Only Functions
- **`get-user(user)`**: Returns the full user data record.  
- **`get-user-tier(user)`**: Returns the current tier of a user.  
- **`get-user-weighted-score(user)`**: Returns the weighted score of a user.  
- **`get-thresholds()`**: Returns the current tier thresholds.

---

## Privilege Escalation Logic
1. Users accumulate raw scores (`base-score`) through activity.  
2. Weighted score is calculated:  
```

weighted-score = (base-score * weight-multiplier) / 100

```
3. Tier is determined based on weighted score and configured thresholds.  
4. Users automatically escalate or downgrade tiers as scores cross thresholds.

---

## Security Considerations
- Only the contract owner can configure thresholds or adjust user weights.  
- Registration prevents duplicate users.  
- Score updates and tier calculations are deterministic and transparent.  

---

## Use Cases
- Reputation-based access control  
- Gamified community privilege management  
- Decentralized tiered reward systems  
- User activity tracking with automated privilege escalation  

---

## License
This project is open-source and available for use, modification, and integration.
```
