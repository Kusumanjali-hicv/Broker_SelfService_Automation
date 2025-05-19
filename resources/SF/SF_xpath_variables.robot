
*** Variables ***

#Login Variables
${USERNAME_FIELD}    //*[@id="username"]
${PASSWORD_FIELD}    //*[@id="password"]
${signInButton}    //*[@id="Login"]

#Contact ID Verification Variables
${contact_name}    //lightning-formatted-name[@slot="primaryField"]
${details_tab}    //a[@id="detailTab__item" and @data-label="Details"]
${marital_status_visible}    //div[contains(@class, 'slds-form-element__control')]//span[contains(@class, 'test-id__field-value')]//lightning-formatted-text[@slot="outputField"]
${marital_status_field}    //div[contains(@class, 'slds-form-element__control')]//span[contains(@class, 'test-id__field-value')]//lightning-formatted-text[@slot="outputField"]