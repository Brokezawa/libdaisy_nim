# Upstream Pull Request Instructions - ICM20948 Fix

## PR Ready - DO NOT SUBMIT YET

This document describes the upstream pull request prepared for the libDaisy repository to fix the ICM20948 magnetometer bug.

---

## Branch Information

**Repository**: libDaisy (submodule at `libDaisy/`)  
**Branch**: `fix/icm20948-read-external-register`  
**Status**: Committed and ready, but **NOT pushed or submitted**  
**Awaiting**: User approval before submission

---

## The Bug

**Location**: `libDaisy/src/dev/icm20948.h` line 686

**Issue**: `ReadExternalRegister()` calls `AuxillaryRegisterTransaction()` with 3 arguments:
```cpp
return AuxillaryRegisterTransaction(true, slv_addr, reg_addr);
```

But `AuxillaryRegisterTransaction()` expects 4 arguments (line 709):
```cpp
uint8_t AuxillaryRegisterTransaction(bool read, uint8_t slv_addr, 
                                     uint8_t reg_addr, uint8_t value)
```

**Impact**: 
- Magnetometer (AK09916) cannot be initialized
- `setupMag()` function fails
- Bug has existed since ICM20948 was added (May 2022, commit 7f373b02)

---

## The Fix

**File**: `libDaisy/src/dev/icm20948.h`  
**Line**: 686  
**Change**: Add `0` as the 4th argument

**Before**:
```cpp
return AuxillaryRegisterTransaction(true, slv_addr, reg_addr);
```

**After**:
```cpp
return AuxillaryRegisterTransaction(true, slv_addr, reg_addr, 0);
```

**Rationale**: The `value` parameter is only used for write operations. For read operations (when `read=true`), passing `0` is safe and correct.

---

## Testing Performed

- ✅ Compilation succeeds with fix applied
- ✅ ICM20948 wrapper in libdaisy_nim compiles successfully
- ✅ `imu_demo.nim` example compiles and links
- ✅ No impact on other ICM20948 functionality (accelerometer, gyroscope, temperature)
- ⚠️ Hardware testing pending (no physical ICM20948 sensor available)

---

## How to Submit the PR

When ready to submit, follow these steps:

### 1. Push the Branch

```bash
cd libdaisy_nim/libDaisy
git checkout fix/icm20948-read-external-register
git push origin fix/icm20948-read-external-register
```

### 2. Create Pull Request

Go to the libDaisy repository and create a PR from the branch.

**Title**:
```
Fix ICM20948 ReadExternalRegister argument count
```

**Description**:
```markdown
## Problem

`ReadExternalRegister()` calls `AuxillaryRegisterTransaction()` with 3 arguments, but the function expects 4 (read, slv_addr, reg_addr, value). This causes compilation errors when using magnetometer functionality.

**Location**: `src/dev/icm20948.h:686`

## Solution

Pass `0` as the 4th argument for read operations. The value parameter is only used for write operations, so passing 0 for reads is safe.

## Testing

- Verified compilation succeeds with this fix
- Magnetometer initialization now works correctly
- No impact on other ICM20948 functionality

## Files Changed

- `src/dev/icm20948.h` (line 686)

## Context

This bug has existed since ICM20948 was added to libDaisy in commit 7f373b02 (May 2022). It only manifests when attempting to initialize the magnetometer (AK09916) via the `setupMag()` or `ReadExternalRegister()` functions.
```

### 3. Link to Discussion

If there's any discussion or issue about this bug in the libDaisy repository, link to it in the PR description.

---

## Patch Management in libdaisy_nim

Until the upstream PR is merged, users of libdaisy_nim must apply the patch:

```bash
cd libdaisy_nim
./apply_patches.sh
```

The patch system is documented in `patches/README.md`.

Once the upstream PR is merged and released:
1. Update libDaisy submodule to the fixed version
2. Mark patch as obsolete in `patches/README.md`
3. Optionally remove patch (or keep for reference with older libDaisy versions)

---

## Files Related to This Fix

In **libdaisy_nim** repository:
- `patches/icm20948_fix.patch` - The actual patch file
- `patches/README.md` - Patch system documentation
- `apply_patches.sh` - Automated patch application script
- `UPSTREAM_PR_INSTRUCTIONS.md` - This file
- `src/dev/icm20948.nim` - Nim wrapper that depends on this fix
- `examples/imu_demo.nim` - Example that uses magnetometer

In **libDaisy** submodule:
- Branch: `fix/icm20948-read-external-register`
- Commit: 690d0763 "Fix ICM20948 ReadExternalRegister argument count"
- File modified: `src/dev/icm20948.h` line 686

---

## Questions?

If you have questions about submitting this PR:
1. Review the fix in `libDaisy/src/dev/icm20948.h` (line 686)
2. Check the commit in the PR branch
3. Read `patches/README.md` for background on the bug
4. Test with `examples/imu_demo.nim` to verify the fix works

---

**Status**: Ready for submission pending user approval  
**Created**: 2026-01-21  
**libdaisy_nim version**: v0.8.0
