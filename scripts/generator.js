/* Global variables */
const puppeteer = require('puppeteer');
const fetch = require("node-fetch");
const moment = require("moment");
const parseString = require("xml2js").parseString;

const hardware_key = process.env.HARDWARE_KEY;
const system_type = process.env.SYSTEM_TYPE.toLowerCase();
const system_name = process.env.SYSTEM_NAME;
const system_id = process.env.SYSTEM_ID;

const system_parameters = {
    crm: {
        insnr: "20253931",
        prod: "01200615320800000556",
        prodver: "01200314690900001287"
    },
    isu: {
        insnr: "20253728",
        prod: "01200615320800000659",
        prodver: "01200615320900001296"
    },
    java: {
        insnr: "20253729",
        prod: "01200314690800000134",
        prodver: "67838200100900005868"
    }
}
/* End global variables */

// Uses headless browser to log in to the SAP ONE Support Launchpad and retrieves a cookie allowing session persistence
async function authenticate() {
    const browser = await puppeteer.launch({args: ["--no-sandbox", "--disable-setuid-sandbox"] });
    const page = await browser.newPage();

    await page.goto('https://launchpad.support.sap.com/#/licensekey/wizard');
    // Dirty SAML has two form-based redirects, so need to wait for each of those to finish in turn
    await page.waitForNavigation();
    await page.waitForNavigation();

    // Login to IDP
    await page.type('#j_username', process.env.SAP_USER);
    await page.type('#j_password', process.env.SAP_PASS);
    await page.click('button[type=submit]');
    await page.waitFor(10000);

    let cookies = await page.cookies("https://launchpad.support.sap.com");
    
    await browser.close();

    // Construct cookies header
    let cookie = "";
    for (i in cookies) {
        cookie += cookies[i].name + "=" + cookies[i].value + ";"
    }
    return cookie;
};

// returns the number of active systems and the X-CSRF-Token which must be used in future requests
async function get_active_systems_by_sid(cookie, sysid) {
    const url = `https://launchpad.support.sap.com/services/odata/svt/systemdatasrv/SystemOverviewSet?$skip=0&$top=100&$orderby=INSNR%20asc&$filter=actIns%20eq%20%27X%27%20and%20substringof(%27${sysid}%27,SYSNR)%20and%20delete_flag%20eq%20%27%27&sap-language=en`

    const response = await fetch(url, {
        headers: {
            "Cookie": cookie,
            "Accept": "application/json",
            "X-CSRF-Token": "Fetch" 
        },
    })
    .catch(console.error);

    const body = await response.json();
    const headers = response.headers;

    return {
        "x_csrf_token": headers.get("x-csrf-token"),
        "body": body
    }
}

// Gets number of inactive systems asoociated with a particular SID
async function get_inactive_systems_by_sid(cookie, csrf_token, sysid) {
    const url = `https://launchpad.support.sap.com/services/odata/svt/systemdatasrv/SystemOverviewSet?$skip=0&$top=100&$orderby=INSNR%20asc&$filter=actIns%20eq%20%27X%27%20and%20substringof(%27${sysid}%27,SYSNR)%20and%20delete_flag%20eq%20%27X%27&sap-language=en`

    const response = await fetch(url, {
        headers: {
            "Cookie": cookie,
            "Accept": "application/json",
            "X-CSRF-Token": csrf_token
        },
    })
    .catch(console.error);

    return await response.json();
}

// Creates or updates information related to a particular SID
async function create_update_system(cookie, csrf_token, action, sysnr, sysid, sysname, hwkey) {
    const url = "https://launchpad.support.sap.com/services/odata/i7p/odata/bkey/Submit?sap-language=en"

    // Set expiry date 3 months from today (YYYYMMDD)
    var date = new Date()
    var expiry = moment(date.setMonth(date.getMonth() + 3)).format("YYYYMMDD");

    const payload = `{
        "actcode":"${action}",
        "Uname":"S0019332459",
        "sysdata":"[
            {
                \\"name\\":\\"insnr\\",
                \\"value\\":\\"${system_parameters[system_type].insnr}\\"
            },
            {
                \\"name\\":\\"prod\\",
                \\"value\\":\\"${system_parameters[system_type].prod}\\"
            },
            {
                \\"name\\":\\"prodver\\",
                \\"value\\":\\"${system_parameters[system_type].prodver}\\"
            },
            {
                \\"name\\":\\"sysnr\\",
                \\"value\\":\\"${sysnr}\\"
            },
            {
                \\"name\\":\\"Nocheck\\",
                \\"value\\":\\"\\"
            },
            {
                \\"name\\":\\"sysid\\",
                \\"value\\":\\"${sysid}\\"
            },
            {
                \\"name\\":\\"sysname\\",
                \\"value\\":\\"${sysname}\\"
            },
            {
                \\"name\\":\\"systype\\",
                \\"value\\":\\"TEST\\"
            },
            {
                \\"name\\":\\"sysdb\\",
                \\"value\\":\\"MSSQLSRV\\"
            },
            {
                \\"name\\":\\"sysos\\",
                \\"value\\":\\"NT/INTEL\\"
            }    
        ]", 
        "matdata": "[
            {
                \\"hwkey\\":\\"${hwkey}\\",
                \\"prodid\\":\\"J2EE-Engine\\",
                \\"quantity\\":\\"2147483647\\",
                \\"keynr\\":\\"0\\",
                \\"expdat\\":\\"99991231\\",
                \\"status\\":\\"New entry\\"
            },
            {
                \\"hwkey\\":\\"${hwkey}\\",
                \\"prodid\\":\\"Maintenance\\",
                \\"quantity\\":\\"2147483647\\",
                \\"keynr\\":\\"0\\",
                \\"expdat\\":\\"${expiry}\\",
                \\"status\\":\\"New entry\\"
            }
        ]"
    }`

    return await fetch(url, {
        method: "post", 
        headers: { 
            "Content-Type": "application/json",
            "Cookie": cookie,
            "X-CSRF-Token": csrf_token
        },
        body: payload
    })
    .then(res => res.text())
    .then(data => { console.log(data) })
    .catch(console.error);
}

// Reactivates inactive system
async function reactivate_system(cookie, csrf_token, sysnr) {
    const url = `https://launchpad.support.sap.com/services/odata/svt/systemdatasrv/UtilitySet?sap-language=en`

    const payload = {
        SYSNR: sysnr,
        ACTION: "Reactivate"
    }

    return await fetch(url, {
        method: "post",
        headers: {
            "Content-Type": "application/json",
            "Cookie": cookie,
            "X-CSRF-Token": csrf_token
        },
        body: JSON.stringify(payload)
    })
    .then(res => res.text())
    .then(data => { console.log(data) })
    .catch(console.error);
}

// Retrieves licence keys associates with a SID
async function get_licence_keys(cookie, csrf_token, sysnr) {
    const url = `https://launchpad.support.sap.com/services/odata/i7p/odata/bkey/LicenseKeys?$filter=Sysnr%20eq%20%27${sysnr}%27%20and%20Uname%20eq%20%27S0019332459%27&sap-language=en`

    const response = await fetch(url, {
        headers: {
            "Cookie": cookie,
            "X-CSRF-Token": csrf_token
        }
    })
    .catch(console.error);

    const xml = await response.text();

    // Extract licence keys from XML response
    var licences = [];
    parseString(xml, function (err, result) {
        result["feed"]["entry"].forEach(function (item) {
            licences.push(item["content"][0]["m:properties"][0]["d:Keynr"].toString());
        })
    });

    return licences;
}

// Print key data
async function get_key_data(cookie, csrf_token, keys) {
    const url = `https://launchpad.support.sap.com/services/odata/i7p/odata/bkey/FileContent(Keynr='%5B%7B%22Keynr%22%3A%22${keys[0]}%22%7D%2C%7B%22Keynr%22%3A%22${keys[1]}%22%7D%5D')/$value`

    const response = await fetch(url, {
        headers: {
            "Cookie": cookie,
            "X-CSRF-Token": csrf_token
        }
    })
    .catch(console.error);

    return await response.text();
}

async function main() {
    // Log in to SAP portal and get cookies required for future requests
    const cookie = await authenticate();

    // Get data about active systems and the X-CSRF-Token for future requests 
    const active_systems = await get_active_systems_by_sid(cookie, system_id);
    const csrf_token = active_systems["x_csrf_token"];
    const active_sids = active_systems["body"].d.__count;

    // Action defines whether we create or update a system
    let action = "edit";
    let sysnr;

    // Check if any SIDs are still active
    if (active_sids >= 1) {
        // Get SYSNR of first active SID
        sysnr = active_systems["body"].d.results[0].SYSNR;
    }   
    // No active licences exist for specified SID
    else if (active_sids == 0) { 
        // Check for inactive licences
        let inactive_sids = await get_inactive_systems_by_sid(cookie, csrf_token, system_id);

        // Reactivate inactive licence
        if (inactive_sids.d.__count > 0) {
            sysnr = inactive_sids.d.results[0].SYSNR;
            await reactivate_system(cookie, csrf_token, sysnr);
        } 
        else {
            // No active or inactive systems exist, therefore we need to create one
            action = "add";
        }
    }
    else {
        // Problem with the retrieved active sid count
        console.log(`Error validating active sid count. Result: ${active_sids}`);
        console.log("Exiting");
        process.env.exit(1);
    }

    // Create new or modify existing system
    await create_update_system(cookie, csrf_token, action, sysnr, system_id, system_name, hardware_key);

    // Retrieve licence key numbers
    const keys = await get_licence_keys(cookie, csrf_token, sysnr);

    // Get licence key data
    const key_data = await get_key_data(cookie, csrf_token, keys);

    console.log(key_data);
}

main();