

```
nix why-depends /run/current-system /nix/store/2ikbcg3zvzfy5ac06fdqv186cjg62ax2-libyuv-1908
```

```
nix-store --query --referrers /nix/store/0yyfnqaj8yfzh9mx2xy0fcwziv4lghy1-gd-2.3.3

/nix/store/0yyfnqaj8yfzh9mx2xy0fcwziv4lghy1-gd-2.3.3
/nix/store/d3y8921rjkjn8sa0ic4clmagma5b1cm8-graphviz-12.2.1
```

to see the root

```
[root@nixos-sd-card:/nix/store]# nix-store --query --roots /nix/store/2ikbcg3zvzfy5ac06fdqv186cjg62ax2-libyuv-1908
/nix/var/nix/profiles/per-user/root/profile-20-link -> /nix/store/icss501v16v6wblb28qf5ff5fc6gk9w6-profile
```