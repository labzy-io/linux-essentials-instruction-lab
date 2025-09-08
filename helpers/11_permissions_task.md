### Helper — Step 11: Permissions Challenge (Exact Commands)

> Use this only if you’re stuck. These commands implement the required state exactly.

```bash
# 1) Workspace
mkdir -p ~/playground/secure-project/{secrets,public}

# 2) Files with exact content
echo "TOP SECRET" > ~/playground/secure-project/secrets/plan.txt
echo "Welcome to the project" > ~/playground/secure-project/public/readme.txt

# 3) Permissions
chmod 700 ~/playground/secure-project/secrets
chmod 600 ~/playground/secure-project/secrets/plan.txt
chmod 755 ~/playground/secure-project/public
chmod 644 ~/playground/secure-project/public/readme.txt

# 4) (Optional) Inspect
stat -c "%A %a %U %G %n" ~/playground/secure-project/secrets ~/playground/secure-project/secrets/plan.txt
stat -c "%A %a %U %G %n" ~/playground/secure-project/public  ~/playground/secure-project/public/readme.txt
```
