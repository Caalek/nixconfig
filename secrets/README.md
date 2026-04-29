# Secrets (agenix)

## Recipients

Age public keys used to encrypt secrets:

- `age153dpcky2ywz64nqf44xpc7euz9lcuzzsnwks70hnktgng205953qtmtjl7` — vm@nixos (initialized during first deploy: `age-keygen -o /etc/age/key.txt`)

## Adding a new machine

```bash
# On the new machine, generate a dedicated age key
sudo age-keygen -o /etc/age/key.txt

# Copy the public key output
# Public key: age1abc...

# On your laptop, re-encrypt secrets for both keys
agenix -e secrets/borg-passphrase.age -i ~/.ssh/id_ed25519
```
