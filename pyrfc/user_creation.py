#!/usr/bin/env python

import argparse, csv
from itertools import islice
from pyrfc import Connection

def map_users(csv_file):
    users = {}

    with open(csv_file, 'rb') as f:
        reader = csv.reader(f)

        rownum = 0

        for row in reader:
            if rownum > 0:
                user_name = row[0]
                role = row[4]
                profile = row[5]

                user = {}

                # User does not exist in dictionary. Create it
                if user_name not in users.keys():

                    users[user_name] = {
                        "full_name": row[1],
                        "password": row[2],
                        "user_type": row[3],
                        "roles": [],
                        "profiles": []            
                    }

                # User exists. Add their roles and profiles
                user = users[user_name]
                if role != "":
                    user["roles"].append(role)
                
                if profile != "":
                    user["profiles"].append(profile)

            rownum += 1

    return users

def delete_users(conn, users):
    for user in users:
        # If user exists in system, delete it
        result = conn.call("BAPI_USER_EXISTENCE_CHECK", USERNAME=user)
        if result["RETURN"]["MESSAGE"] == "User {0} exists".format(user):
            print("Deleting user: {0}".format(user))
            result = conn.call("BAPI_USER_DELETE", USERNAME=user)
        else:
            print("User: {0} does not exist".format(user))

def create_users(conn, users):
    for user in users:
        logondata = { "USTYP": users[user]["user_type"] }
        password = { "BAPIPWD": users[user]["password"] }
        result = conn.call("BAPI_USER_CREATE1", USERNAME=user, LOGONDATA=logondata, ADDRESS={}, PASSWORD=password)
        print(result)

    print("\n")

def assign_profiles(conn, users):
    for user in users:        
        profiles = []
        for profile in users[user]["profiles"]:
            profiles.append({
                "BAPIPROF": profile
            })

        if len(users[user]["profiles"]) > 0:
            result = conn.call("BAPI_USER_PROFILES_ASSIGN", USERNAME=user, PROFILES=profiles)
            print(result)

    print("\n")

def assign_groups(conn, users):
    for user in users:
        roles = []
        for role in users[user]["roles"]:
            roles.append({
                "AGR_NAME": role
            })
        
        if (len(users[user]["roles"]) > 0):
            result = conn.call("BAPI_USER_ACTGROUPS_ASSIGN", USERNAME=user, ACTIVITYGROUPS=roles)
            print(result)

def main():
    # Parse command line args
    parser = argparse.ArgumentParser(description="SAP users creation")
    parser.add_argument("-h", "--as-hostname", type=str, required=True, help="Application server hostname")
    parser.add_argument("-u", "--as-username", type=str, required=True, help="Application server username")
    parser.add_argument("-p", "--as-password", type=str, required=True, help="Application server password")
    parser.add_argument("-f", "--csv-file", type=str, required=True, help="CSV file containing user and profile details")
    parser.add_argument("-dp", "--default-user-password", type=str, required=True, help="Password for default user: AGLSRVUSR")
    parser.add_argument("-d000", "--ddic-000-password", type=str, required=True, help="Password for DDIC user in client 000")
    parser.add_argument("-d100", "--ddic-100-password", type=str, required=True, help="Password for DDIC user in client 100")
    args = parser.parse_args()

    # Set up connection to PAS with client 000
    conn = Connection(ashost=args.as_hostname, sysnr='10', client='000', user=args.as_username, passwd=args.ddic_000_password)

    # Create default user and assign profiles
    conn.call("BAPI_USER_CREATE1", \
        USERNAME="AGLSRVUSR", \
        LOGONDATA={ "USTYP": "S" }, \
        PASSWORD={ "BAPIPWD": args.default_user_password }
    )

    conn.call("BAPI_USER_PROFILES_ASSIGN", \
        USERNAME="AGLSRVUSR", \
        PROFILES=[
            { "BAPIPROF": "SAP_ALL" }, 
            { "BAPIPROF": "SAP_NEW" }
        ]
    )

    # Set up connection to PAS with client 100
    conn = Connection(ashost=args.as_hostname, sysnr='10', client='100', user=args.as_username, passwd=args.ddic_100_password)

    users = map_users(args.csv_file)

    delete_users(conn, users)

    create_users(conn, users)

    assign_profiles(conn, users)

    assign_groups(conn, users)

main()

