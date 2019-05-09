#!/usr/bin/env python3

import argparse, os, re, subprocess

def main():
    # Parse command line arguments
    parser = argparse.ArgumentParser(description="Generate Ansible inventory file")
    parser.add_argument("-r", "--roles", nargs="+", type=str, required=True, help="List of roles", default=[])
    parser.add_argument("-s", "--sub-roles", nargs="+", type=str, required=True, help="List of sub roles", default=[])
    parser.add_argument("-o", "--out-file", type=str, required=True, help="File path for inventory file")
    args = parser.parse_args()

    # Change to Terraform working directory
    if os.path.exists("../terraform"):
        os.chdir("../terraform")
    else:
        print("Failed to enter Terraform directory")
        exit(1)

    generate_file(args.roles, args.sub_roles, args.out_file)

def generate_file(roles, sub_roles, out_file):
    f = open(out_file, "w+")

    for role in roles:
        children = []

        for sub_role in sub_roles:
            full_role = "{}-{}".format(role, sub_role)
            f.write("[{}]\n".format(full_role))
            children.append(full_role)

            tf_output = subprocess.run(["terraform", "output", "ip_addresses_{}".format(full_role)], stdout=subprocess.PIPE)

            # Strip commas and newline chars and store in array
            ip_addresses = re.sub(',','', tf_output.stdout.decode("utf-8")).splitlines()

            for ip in ip_addresses:
                variables=""

                if sub_role == "data":
                    print("do stuff here...")

                f.write("{} {}\n".format(ip, variables))

            f.write("\n")

        # Parent role
        f.write("[{}:children]\n".format(role))

        # Children
        for child in children:
            f.write("{}\n".format(child))
                
        f.write("\n")

main()

