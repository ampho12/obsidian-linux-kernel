## 1) `ranges` Basics

Each `ranges` tuple maps _child_ → _parent_ along a bus:

```
< child-address  parent-address  size >
```

Where the number of cells for each field is:

- **child-address**: `#address-cells` of the _child bus node_ (the node that has the `ranges` property)
    
- **parent-address**: `#address-cells` of the _parent bus_
    
- **size**: `#size-cells` of the _child bus node_. 
    

> Multi-cell values are big-endian concatenations of 32‑bit cells: `<H L>` ⇒ `(H << 32) | L`.

---

# Example DTS

The original snippet mixed cell counts in a couple of places. Below is a consistent version with comments. (I’ve preserved your intent and numbers, adding any missing "third" address cells as `0x00000000` where required.)

```dts
/ {
  axi: axi {
    /* Child bus uses 2/2 cells; root is identity-mapped across a large window */
    #address-cells = <2>;
    #size-cells = <2>;

    ranges = <0x00 0x00000000   0x00 0x00000000   0x10 0x00000000>,
             <0x10 0x00000000   0x10 0x00000000   0x01 0x10000000>;
             /* ^ fixed missing 0 in second tuple */

    pcie2: pcie@xxxx {
      /* pcie2’s registers live in AXI (parent) space */
      reg = <0x10 0x00120000   0x0 0x9310>;  // → 0x1000120000 size 0x9310

      /* The PCIe child bus uses 3 addr cells (PCI convention) and 2 size cells */
      #address-cells = <3>;
      #size-cells = <2>;

      ranges = <0x02000000 0x00000000 0x00000000   /* child base */
                0x0000001f 0x00000000               /* parent (AXI) base */
                0x00000000 0xfffffffc>;             /* size */

      rpi1: rpi1 {
        /* rpi1 is a bridge-like node on the PCIe child bus */
        #address-cells = <3>;
        #size-cells = <2>;

        /* Map rpi1’s child space (starting at 0xC0:0x40000000) into PCIe child space */
        ranges = <0x000000c0 0x40000000 0x00000000   /* child base (3 cells) */
                  0x02000000 0x00000000 0x00000000   /* parent = PCIe child base */
                  0x00000000 0x00410000>;            /* size = 0x410000 */

        rp1_uart0: serial@xxxxx {
          /* reg must match rpi1’s #address/size cells: 3 addr + 2 size */
          reg = <0x000000c0 0x40030000 0x00000000   /* address */
                 0x00000000 0x00000100>;            /* size 0x100 */
        };
      };
    };
  };
};
```

### Notes on the fixes

- **Cell-count consistency**: With `#address-cells = <3>` the child address fields in both `ranges` and `reg` must have **3 cells**. The original had only 2 in places; above we add the missing third cell as `0x00000000` to match the intent.
    
- **AXI `ranges` typo**: `0x10 0x0000000` → `0x10 0x00000000`.
    

---

## 3) Worked Translations

### 3.1 `pcie2` base in AXI (and absolute) space

- `reg = <0x10 0x00120000 0x0 0x9310>` ⇒ address = `(0x10 << 32) | 0x00120000 = 0x1000120000`.
    
- AXI is identity-mapped to root per its first `ranges` tuple, so **absolute base = `0x1000120000`**.
    

### 3.2 `rpi1` base relative to PCIe child space

- `rpi1.ranges` maps child base `<0x000000c0 0x40000000 0x00000000>` to PCIe child base `<0x02000000 0x00000000 0x00000000>` with size `0x410000`.
    

### 3.3 `serial@xxxxx` in `rpi1` → PCIe child

- `serial.reg` = `<0x000000c0 0x40030000 0x00000000 0x00000000 0x00000100>`
    
- Offset within `rpi1` window: `0x40030000 - 0x40000000 = 0x00030000`.
    
- Therefore PCIe child address = `<0x02000000 0x00000000 0x00030000>`.
    

### 3.4 PCIe child → AXI parent (`pcie2.ranges`)

- PCIe child base `<0x02000000 0x00000000 0x00000000>` maps to AXI base `<0x0000001f 0x00000000>`.
    
- Add the offset `0x00030000` ⇒ AXI address `<0x0000001f 0x00030000>` ⇒ **`0x1f00030000`**.
    

---

## 4) Sanity Checks & Pitfalls

- **Match cell counts** everywhere (`reg`, `ranges`, `dma-ranges`). Mismatches are the #1 source of confusion.
    
- **PCI/PCIe child addresses** usually use 3 cells: `phys.hi`, `phys.mid`, `phys.lo`. If you don’t care about the low 32 bits, still include the third cell as `0x00000000`.
    
- **Arithmetic**: Always compute offsets in the child space, then apply the parent mapping.
    
- **Window sizes** must be large enough to cover your child registers (`serial`’s `0x100` fits inside `rpi1`’s `0x410000`).
    

---

## 5) Quick Formulae

- Two-cell value: `<H L>` ⇒ `H<<32 | L`
    
- Three-cell value: `<A B C>` ⇒ `(B<<32) | C` (with `A` as flags/space encoding on PCIe)
    
- Translate up: `parent_addr = parent_base + (child_addr - child_base)`
    

---

## 6) Final Results (unchanged)

- **`pcie2` base**: `0x1000120000`
    
- **`serial@xxxxx` absolute**: `0x1f00030000`