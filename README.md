fusionsync
==========
fusionsync is a script which allows the syncing of local drupal database data to a Google fusion table.

Installation / Setup
--------------------
1. Download (as a minimum) the files: `fusionsync.sh`, `common.sh`, and `RUN_ME_FIRST.sh`
2. Find out the relevant details:
  * Your fusion table ID - Located in File > About this table when viewing the appropriate table
  * Your OAuth credentials - Can be found or set-up in the [Google Developer Console](https://console.developers.google.com/). To set up:
    * Visit the link and select/create a new project
    * Activate the Fusion tables API. This can be done by clicking on 'API' in the sidebar, then searching for the relevant API
    * OAuth credentials require a product name. Click on 'Consent screen' in the sidebar, and enter an appropriate product name
    * Finally, click on 'Credentials' and under the 'OAuth' heading, click the 'Create new Client ID' button. Choose the 'Installed application' option on the pop-up window that appears
3. Create a file `credentials.sh` in the same directory as the other files. Copy your OAuth Client ID and Client secret, and place them in credentials.sh in the following format:

  ```
    CLIENT_ID=<your client ID here>
    CLIENT_SECRET=<your client secret here>
  ```
4. Run `RUN_ME_FIRST.sh` on a computer that has access to a web browser and follow the prompts. A web browser is required for the initial authentication step. Once this step is performed, the program can operate on a system without one as long as credentials.sh is present on the same system

Tests
-----
[Bats](https://github.com/sstephenson/bats) is required to run the tests inside the `/tests` directory. Note that the tests must be placed in the same directory as the main files to work properly.
