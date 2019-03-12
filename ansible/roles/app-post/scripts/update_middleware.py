#!/usr/bin/env python

import argparse
from pyrfc import Connection

def main():
    # Parse command line args
    parser = argparse.ArgumentParser(description="Update middleware parameters")
    parser.add_argument("-a", "--as-hostname", type=str, required=True, help="Application server hostname")
    parser.add_argument("-u", "--as-username", type=str, required=True, help="Application server username")
    parser.add_argument("-p", "--as-password", type=str, required=True, help="Application server password")
    parser.add_argument("-s", "--source-sid", type=str, required=True, help="Source SID (e.g. P1)")
    parser.add_argument("-t", "--target-sid", type=str, required=True, help="Target SID (e.g. A3)")    
    args = parser.parse_args()

    # Set up connection
    conn = Connection(ashost=args.as_hostname, sysnr='10', client='100', user=args.as_username, passwd=args.as_password)

    systems = [ "C", "I", "M", "X" ]
    xt_mapping = []

    for system in systems:
        xt_mapping.append({
            "SOURCE_SID": "{0}{1}".format(system, args.source_sid),
            "TARGET_SID": "{0}{1}".format(system, args.target_sid)
        })

    print(conn.call("Z_CBA_UPDATE_MIDDLWAREPARAMS", XT_MAPPING=xt_mapping))

main()