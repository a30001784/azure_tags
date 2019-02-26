
#!/usr/bin/env python

import argparse
from pyrfc import Connection

def main():
    # Parse command line args
    parser = argparse.ArgumentParser(description="Assign Logical Paths")
    parser.add_argument("-a", "--as-hostname", type=str, required=True, help="Application server hostname")
    parser.add_argument("-u", "--as-username", type=str, required=True, help="Application server username")
    parser.add_argument("-p", "--as-password", type=str, required=True, help="Application server password")
    args = parser.parse_args()

    # Set up connection
    conn = Connection(ashost=args.as_hostname, sysnr='10', client='100', user=args.as_username, passwd=args.as_password)

    logical_path = conn.call("Z_IBA_LOGICPATH_DEF")
    print(logical_path)

main()