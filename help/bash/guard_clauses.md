# Guard Clause Rules

1. Procedural installers
    - every step uses `|| return 1` or `|| exit 1`
    
2. Selector fallbacks
    - no guards inside; guard the call
    
3. Native install and manual fallback
    - no guard on native install
    
4. Bypass helpers
    - never put guards inside
    - guard at call site
    
5. Function calls inside conditionals
    - must guard
    
6. Dispatchers
    - no guards
    
7. Manual fallback helpers
    - never guard
    
8. Atomic commands outside conditionals
    - no guard
    
9. Teardown helpers 
    - always guard
    
10. If failure should abort
    - guard 

11. If failure should fall back 
    - don't guard
