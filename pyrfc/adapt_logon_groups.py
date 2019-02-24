#!/usr/bin/env python

import argparse, json, os
from pyrfc import Connection

def smlg_get_setup(connection, group_type):
    return connection.call('SMLG_GET_SETUP', GROUPTYPE=group_type)

def import_mapping_table(infile):
    with open(infile, "r") as f:
        return json.load(f)

def update_table(connection, source_table, mapping_table, source_sid, target_sid, group_type):
    erfc_setup_dst = []

    erfc_setup_src = source_table['ERFC_SETUP']
    for e in erfc_setup_src:
        # Find/replace `source_sid` for `target_sid` in the CLASSNAME field and mark the row for update
        if e['CLASSNAME'].startswith(source_sid):
            e['CLASSNAME'] = e['CLASSNAME'].replace(source_sid, target_sid)
            e['MODIFICATN'] = 'U'
            erfc_setup_dst.append(e)

    setup_dst = []

    setup_src = source_table['SETUP']
    for s in setup_src:
        # Try find entry in mapping table for source instance name
        row = get_mapping_table_row(mapping_table, "source_instance_name", s['APPLSERVER'].upper())

        # Mark all entries for deletion where a corresponding row cannot be found in the mapping table
        if row == None:
            print("No entry found in mapping table for source instance name: {0}".format(s['APPLSERVER']))
            print("Flagging entry for deletion...")
            s['MODIFICATN'] = 'D'
            setup_dst.append(s)
        else:
            # When we need to modify one of the columns that makes up the primary key (CLASSNUM, APPLSERVER or GROUPTYPE),
            # we cannot update the entry. Therefore we must delete the existing entry and insert another with the updated fields
            s1, s2 = s.copy(), s.copy()

            # Mark existing row for deletion
            s1['MODIFICATN'] = 'D'
            setup_dst.append(s1)

            # Find rows with the CLASSNAME specific to `source_sid` and update it with the `target_sid`
            if s2['CLASSNAME'].startswith(source_sid):
                s2['CLASSNAME'] = s2['CLASSNAME'].replace(source_sid, target_sid)
            
            # Update the target instance name and mark the row for insert
            s2['APPLSERVER'] = row['target_instance_name']
            s2['MODIFICATN'] = 'I'
            setup_dst.append(s2)

    return connection.call("SMLG_MODIFY", GROUPTYPE=group_type, MODIFICATIONS=setup_dst, ERFC_MODIFICATIONS=erfc_setup_dst)

def get_mapping_table_row(mapping_table, key, val):
    for row in mapping_table: 
        if row[key] == val:
            return row

    return None
          
def main():
    # Parse command line args
    parser = argparse.ArgumentParser(description="SAP profiles importer")
    parser.add_argument("-h", "--as-hostname", type=str, required=True, help="Application server hostname")
    parser.add_argument("-u", "--as-username", type=str, required=True, help="Application server username")
    parser.add_argument("-p", "--as-password", type=str, required=True, help="Application server password")
    parser.add_argument("-s", "--source-sid", type=str, required=True, help="SID for source SAP profiles")
    parser.add_argument("-t", "--target-sid", type=str, required=True, help="SID for target SAP profiles")
    args = parser.parse_args()

    # Set up connection
    conn = Connection(ashost=args.as_hostname, sysnr='10', client='100', user=args.as_username, passwd=args.as_hostname)   

    logon_groups = smlg_get_setup(conn, '')
    rfc_server_groups = smlg_get_setup(conn, 'S')

    mapping_table = import_mapping_table("./mapping_table.json")

    # Logon groups
    result_lg = update_table(conn, logon_groups, mapping_table, args.source_sid, args.target_sid, '')

    # RFC server groups
    result_sg = update_table(conn, rfc_server_groups, mapping_table, args.source_sid, args.target_sid, 'S')

    if result_lg != None:
        print(result_lg)
    
    if result_sg != None:
        print(result_sg)

main()