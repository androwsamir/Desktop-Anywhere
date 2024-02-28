import socket
import subprocess
import os

def get_local_ip():
    try:
        # Create a socket object
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

        # Connect to an external server (Google's DNS server)
        s.connect(("8.8.8.8", 80))

        # Get the current local IP address
        local_ip = s.getsockname()[0]

        return local_ip
    except socket.error:
        return "Unable to determine local IP"

def setStaticIp(interface_name, ip_address, subnet_mask, gateway, dns_primary, dns_alternate):
    try:
        static_ip_command = f'netsh interface ipv4 set address name="{interface_name}" source=static address={ip_address} mask={subnet_mask} gateway={gateway}'
        primery_dns_command = f'netsh interface ipv4 set dns name="{interface_name}" source=static address=8.8.8.8 validate=no'
        alternate_dns_command = f'netsh interface ipv4 add dns name="{interface_name}" address=1.1.1.1 validate=no'
        # Call the command using os.system
        result = os.system(static_ip_command)
        result_dns1 = os.system(primery_dns_command)
        result_dns2 = os.system(alternate_dns_command)

        if result == 0 and result_dns1 == 0 and result_dns2 == 0:
            print("Static IP address, subnet mask, and gateway set successfully.")

    except subprocess.CalledProcessError:
        print("Failed to set static IP. Check your parameters and permissions.")


interface_name = "Wi-Fi"  # Change this to match your network interface name
static_ip = get_local_ip()  # Use your current IP address
subnet_mask = "255.255.255.0"  # Adjust this to match your network
gateway = "192.168.1.1"  # Set your gateway address
dns_primary = "8.8.8.8"  # Preferred DNS server address
dns_alternate = "8.8.4.4"  # Alternate DNS server address
setStaticIp(interface_name, static_ip, subnet_mask, gateway, dns_primary, dns_alternate)