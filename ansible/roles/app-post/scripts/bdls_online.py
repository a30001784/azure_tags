#!/usr/bin/env python

import argparse, re
from pyrfc import Connection

def main():
    # Parse command line args
    parser = argparse.ArgumentParser(description="BDLS Online")
    parser.add_argument("-a", "--as-hostname", type=str, required=True, help="Application server hostname")
    parser.add_argument("-u", "--as-username", type=str, required=True, help="Application server username")
    parser.add_argument("-p", "--as-password", type=str, required=True, help="Application server password")
    parser.add_argument("-s", "--source-sid", type=str, required=True, help="SID for source SAP profiles")
    parser.add_argument("-t", "--target-sid", type=str, required=True, help="SID for target SAP profiles")
    parser.add_argument("-e", "--environment", type=str, required=True, help="Environment type")
    parser.add_argument("-pf", "--profiles-file", type=str, required=True, help="File containing source profile names")
    parser.add_argument("-ef", "--exclusions-file", type=str, required=True, help="File containing table exclusions")
    args = parser.parse_args()

    # Set up connection
    conn = Connection(ashost=args.as_hostname, sysnr='10', client='100', user=args.as_username, passwd=args.as_password)

    logsys_map = []
    with open(args.profiles_file) as f:
        for profile in f.read().splitlines():
            old_logsys = profile
            new_logsys = ""

            regex = r"(AGLMDH)([A-Z]+)"
            match = re.search(regex, old_logsys)

            if match:
                old_env = match.group(2)
                new_logsys = old_logsys.replace(old_env, args.environment)               
            else:
                new_logsys = old_logsys.replace(args.source_sid, args.target_sid)
            
            logsys_map.append({
                "OLD_LS": old_logsys,
                "NEW_LS": new_logsys
            })

    excluded_tables = []
    with open(args.exclusions_file) as f:
        for exclusion in f.read().splitlines():
            excluded_tables.append({
                "TABNAME": exclusion
            })

    result = conn.call("Z_IBA_BDLS_ONLINE", YT_EXCLTABLS=excluded_tables, YT_LOGSYSMAP=logsys_map)
    print(result)
    
main()