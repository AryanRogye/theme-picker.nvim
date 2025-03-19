import os
import subprocess

test_folder = "tests"
test_files = [f for f in os.listdir(test_folder) if f.endswith(".lua")]

for test in test_files:
    test_path = os.path.join(test_folder, test)
    print(f"📂 Running: {test_path}")
    result = subprocess.run(["nvim", "--headless", "-c", f"luafile {test_path}", "-c", "q"], capture_output=True, text=True)
    print(result.stdout)
    print(result.stderr)

print("✅ All tests completed!")
