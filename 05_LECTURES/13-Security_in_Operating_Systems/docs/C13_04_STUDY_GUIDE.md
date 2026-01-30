# Study Guide — OS Security

## The CIA Triad
- **Confidentiality**: Access only for authorised users
- **Integrity**: Data remains unaltered
- **Availability**: System accessible when needed

## UNIX Permissions
```
Symbolic: rwxr-xr-x
Octal:    755

r=4, w=2, x=1
Owner: 7 = 4+2+1 = rwx
Group: 5 = 4+0+1 = r-x
Other: 5 = 4+0+1 = r-x
```

## Vulnerabilities & Protections

| Vulnerability | Protection |
|---------------|------------|
| Buffer overflow | Stack canaries, ASLR |
| Code injection | DEP/NX (non-executable stack) |
| Privilege escalation | Least privilege, sandboxing |

## Useful Commands
```bash
chmod 755 file
chown user:group file
ls -la
stat file
getfacl file
```
