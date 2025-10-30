#!/bin/bash
pass=0
fail=0
failed_examples=""

for example in *.nim; do
  base="${example%.nim}"
  echo "========================================" 
  echo "Testing: $example"
  echo "========================================" 
  
  # Update Makefile TARGET
  sed -i.test_bak "s/^TARGET = .*/TARGET = $base/" Makefile
  
  # Clean and build
  make clean > /dev/null 2>&1
  if make 2>&1 | grep -q "Binary size:"; then
    echo "✓ $example compiled successfully"
    ((pass++))
  else
    echo "✗ $example failed to compile"
    ((fail++))
    failed_examples="$failed_examples\n  - $example"
  fi
  echo
done

echo "========================================"
echo "SUMMARY:"
echo "  Passed: $pass"
echo "  Failed: $fail"
if [ $fail -gt 0 ]; then
  echo -e "\nFailed examples:$failed_examples"
fi
echo "========================================"
