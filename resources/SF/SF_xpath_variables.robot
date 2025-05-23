
*** Variables ***

#Login Variables
${USERNAME_FIELD}    //*[@id="username"]
${PASSWORD_FIELD}    //*[@id="password"]
${signInButton}    //*[@id="Login"]

#Contact ID Verification Variables
${contact_name}    //lightning-formatted-name[@slot="primaryField"]
${details_tab}    //a[@id="detailTab__item" and @data-label="Details"]
${marital_status_visible}      //div[contains(@class, 'slds-form-element__control')]//span[contains(@class, 'test-id__field-value')]//lightning-formatted-text[@slot="outputField"]
${marital_status_field}        //div[contains(@class, 'slds-form-element__control')]//span[contains(@class, 'test-id__field-value')]//lightning-formatted-text[@slot="outputField"]
${primary_contact_field}       //p[@title="Primary Contact"]/following-sibling::p//span[contains(@class, "slds-truncate")]/slot/span
${reservation_status}         //p[@title="Open/Dated Status"]/following-sibling::p//lightning-formatted-text
${checkin_date_xpath}               //span[contains(@class, "test-id__field-label") and text()="Check In Date"]/ancestor::div[contains(@class, "slds-form-element")]/div[contains(@class, "slds-form-element__control")]//lightning-formatted-text
${checkout_date_xpath}             //span[contains(@class, "test-id__field-label") and text()="Check Out Date"]/ancestor::div[contains(@class, "slds-form-element")]/div[contains(@class, "slds-form-element__control")]//lightning-formatted-text          
${tour_wave_allotment_id_xpath}    //span[contains(@class, "test-id__field-label") and text()="Tour Wave Allotment Id"]/ancestor::div[contains(@class, "slds-form-element")]/div[contains(@class, "slds-form-element__control")]//lightning-formatted-text
${number_of_nights_xpath}    //span[contains(@class, "test-id__field-label") and text()="Total Number of Nights"]/ancestor::div[contains(@class, "slds-form-element")]/div[contains(@class, "slds-form-element__control")]//lightning-formatted-number
${number_of_guests_xpath}    //span[contains(@class, "test-id__field-label") and text()="# of Guests"]/ancestor::div[contains(@class, "slds-form-element")]/div[contains(@class, "slds-form-element__control")]//lightning-formatted-number









