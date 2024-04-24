let
  marijan.keys = [ "age1yubikey1q0tpa48d03dy59jcsjsx5a8zv0p8msr89ut7xgr64x5ujgkrn0ceulx4zwv" ];
  nixos-test.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBE+77QNclbcAaTrPBct73LCbSxEp72HCTWV4vXmI9l4" ];
in
{
  "validator-secret-key.age".publicKeys = marijan.keys ++ nixos-test.keys;
}
