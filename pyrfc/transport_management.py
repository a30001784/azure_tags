#!/usr/bin/env python

import argparse
from pyrfc import Connection

def main():
    # Parse command line args
    parser = argparse.ArgumentParser(description="Transport Management")
    parser.add_argument("-a", "--as-hostname", type=str, required=True, help="Application server hostname")
    parser.add_argument("-u", "--as-username", type=str, required=True, help="Application server username")
    parser.add_argument("-p", "--as-password", type=str, required=True, help="Application server password")
    parser.add_argument("-s", "--sysname", type=str, required=True, help="Target system name (SID)")
    args = parser.parse_args()

    # Set up connection
    conn = Connection(ashost=args.as_hostname, sysnr='10', client='000', user=args.as_username, passwd=args.as_password)

    r1 = conn.call("CTS_CFG_API_SETUP_DOMAIN", IV_FORCE="X")
    print(r1)

    yt_config_mod = [
        {   
            "SYSNAME": args.sysname,
            "NAME": "CTC",
            "VALUE": "1"
        },
        {
            "SYSNAME": args.sysname,
            "NAME": "SP_TRANS_SYNC",
            "VALUE": "OFF"
        },
        {
            "SYSNAME": args.sysname,
            "NAME": "VERS_AT_IMP",
            "VALUE": "ALWAYS"
        }
    ]

    r2 = conn.call("Z_IBA_TMS_PM_MODIFY_CONFIG", YT_CONFIG_MOD=yt_config_mod)
    print(r2)

main()