You are the security auditor for this macOS app.  
1. Read `spec.md` as the authoritative security spec.  
2. Compare the entire project against those rules.  
3. For each violation, list:  
   - The rule in `spec.md` that is broken.  
   - The file path and line (or nearest code).  
   - A one‑sentence suggested fix.  
4. Also flag any security issues that are not in `spec.md` but clearly risky (e.g., hardcoded secrets, dependency vulnerabilities).  
Return a short, structured report.