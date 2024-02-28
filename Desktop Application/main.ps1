# Define script paths with full paths and correct separators
$script1 = 'C:\Users\andre\anaconda3\envs\GP\python.exe'
$script1Args = 'serverGUI.py'

# Start script1 in a new window and wait for it to finish
Start-Process -FilePath $script1 -ArgumentList $script1Args -WindowStyle Normal

