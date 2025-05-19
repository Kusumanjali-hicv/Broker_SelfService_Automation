*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    JSONLibrary
Library    String
Resource    ${EXECDIR}/resources/master.robot


*** Variables ***
${ACCESS_TOKEN}
${contact_id} 
${email}
${phone_number}
${first_name}
${last_name}
${packageId}
${tourDate}
${tourWaveAllotmentId}
${json_file_path}    ${EXECDIR}/json/
${checkIn_date}      
${checkOut_date}     
${propertyCode}      
${propertyRoomTypeId}    
${roomTypeCode}      
${inventories}    
${opportunityId}
${uuid}
${message}

*** Keywords ***
Send Credit Eligibility Request
    [Documentation]    POST Credit Eligibility
    [Arguments]    ${marital_status}    ${status_code}    ${message}
    ${headers}    Create Dictionary
    ...    ${X_ENV_NAME}=${X_ENV_VALUE}
    ...    ${AUTHORIZATION_NAME}=Bearer ${ACCESS_TOKEN}

    Create Session    Session    ${BASE_URL}    headers=${headers}    verify=true
    
    ${email}=    Generate Email Id
    ${phone_number}=    Generate Phone Number
    ${JSON_BODY}=    Load JSON From File   ${json_file_path}${CREDIT_ELIGIBILITY}
    Set To Dictionary    ${JSON_BODY}
    ...    email=${email}
    ...    phoneNumber=${phone_number}
    ...    firstName=${first_name}
    ...    lastName=${last_name}
    ...    maritalStatus=${marital_status}

    ${RESPONSE}    POST On Session    Session    ${CREDIT_ELIGIBILITY_URL}    json=${JSON_BODY}    expected_status=any 
    Run Keyword If    '${RESPONSE.status_code}'!='200'    Log    Request returned ${response.status_code} status code    WARN
    
    ${json_string}=     set variable    ${RESPONSE.text}
    ${json_object}=     evaluate      json.loads('''${json_string}''')  json
    ${contactId}=   get value from json    ${json_object}    $.contactId
    

    IF  ${RESPONSE.status_code}!=200
        ${actual_message}=    Get From Dictionary    ${json_object}    errorMessage        
    
    ELSE
        ${actual_message}=    Get From Dictionary    ${json_object}        status
    END

    Should Be Equal As Strings    '${RESPONSE.status_code}'     '${status_code}'
    Should Be Equal As Strings     '${actual_message}'             ${message}

    ${contact_value}=    Set Variable    ${None}
    IF    ${contactId} and len($contactId) > 0
        ${contact_value}=    Set Variable    ${contactId}[0]
    END
    RETURN    ${contact_value}

Send Tour Booking Request
    [Documentation]    POST Reservations Bookings
    ${headers}    Create Dictionary
    ...    ${X_ENV_NAME}=${X_ENV_VALUE}
    ...    ${AUTHORIZATION_NAME}=Bearer ${ACCESS_TOKEN}
    ...    Accept=${CONTENT_TYPE_HEADER_VALUE}

    Create Session    Session    ${BASE_URL}    headers=${headers}    verify=true

    ${JSON_BODY}=    Load JSON From File   ${json_file_path}${TOUR_BOOKING}
    Set To Dictionary    ${JSON_BODY}
    ...    campaignId=${campaignId}
    ...    contactId=${contact_id}  
    ...    packageId=${packageId}  
    ...    tourDate=${tourDate}
    ...    tourWaveAllotmentId=${tourWaveAllotmentId}

    ${RESPONSE}    POST On Session    Session    ${TOURS_BOOKING_URL}    json=${JSON_BODY}
    
    Should Be True    ${RESPONSE.status_code} in [201, 202]    Expected status code to be 201 or 202, but got ${RESPONSE.status_code}
    Log    ${RESPONSE.text}


Send Reservation Request
    [Documentation]    POST Reservations Bookings
    ${headers}    Create Dictionary
    ...    ${X_ENV_NAME}=${X_ENV_VALUE}
    ...    ${AUTHORIZATION_NAME}=Bearer ${ACCESS_TOKEN}
    
    Create Session    Session    ${BASE_URL}    headers=${headers}    verify=true
    ${JSON_BODY}=    Load JSON From File   ${json_file_path}${RESERVATION_BOOKING}
    ${lengthOfStay_int}=    Convert To Integer    ${lengthOfStay}
    ${numberOfGuests_int}=    Convert To Integer    ${numberOfGuests}
    &{reservationRequest}=    Create Dictionary
    ...    checkin=${checkIn_date}
    ...    checkout=${checkOut_date}
    ...    lengthOfStay=${lengthOfStay_int}
    ...    numberOfGuests=${numberOfGuests_int}
    ...    propertyCode=${propertyCode}
    ...    propertyRoomTypeId=${propertyRoomTypeId}
    ...    roomTypeCode=${roomTypeCode}
    ...    inventories=${inventories}

    Set To Dictionary    ${JSON_BODY}
    ...    campaignId=${campaignId}
    ...    tourWaveAllotmentId=${tourWaveAllotmentId}
    ...    packageProductId=${packageId}
    ...    contactId=${contact_id}
    ...    destination=${destination}
    ...    primaryPreferredArrivalDate=${checkIn_date}
    ...    reservationRequest=${reservationRequest}

    ${RESPONSE}    POST On Session    Session    ${RESERVATION_BOOKING_URL}    json=${JSON_BODY}

    IF    '${RESPONSE.status_code}' == '202'
        ${opportunityId}=    Get From Dictionary    ${RESPONSE.json()}    opportunityId
        ${message}=    Get From Dictionary    ${RESPONSE.json()}    message   
        Should Be Equal As Strings    ${message}    Your Stay has been created.
        Set Suite Variable    ${opportunityId}    ${opportunityId}
    END
    
    ${json_string}=     set variable    ${RESPONSE.text}
    
    IF    '${RESPONSE.status_code}' != '202'
        ${status_code}=    Set Variable    ${RESPONSE.status_code}
        Log    *HTML* <font color="red">Reservation Failed with Status Code: ${status_code}</font>    level=ERROR
        Log    *HTML* <font color="red">Error Response: ${json_string}</font>    level=ERROR
        Fail    Reservation request failed
    END
    

Cancel Reservation Booking
    [Documentation]    POST Reservations Bookings
    ${headers}    Create Dictionary
    ...    x-correlation-id=${X_ENV_VALUE}-${uuid}

    Create Session    Session    ${BASE_URL}    headers=${headers}    verify=true

    ${RESPONSE}    DELETE On Session    Session    ${CANCEL_RESERVATION_URL}${opportunityId}
    
    ${json}=    Set Variable    ${RESPONSE.json()}
    IF    '${RESPONSE.status_code}' == '202'
        ${status}=    Get From Dictionary    ${json}    status
        ${message}=    Get From Dictionary    ${json}    message
        Should Be Equal As Strings    ${status}     Success
        Should Be Equal As Strings    ${message}    Reservation Cancelled Successfully
    END
    IF    '${RESPONSE.status_code}' != '202'
        ${status_code}=    Set Variable    ${RESPONSE.status_code}
        Log    *HTML* <font color="red">Cancellation Request Failed with Status Code: ${status_code}</font>    level=ERROR
        Log    *HTML* <font color="red">Error Response: ${json}</font>    level=ERROR
        Fail    Reservation Cancel request failed
    END



Generate Random UUID
    ${uuid}=    Evaluate    str(uuid.uuid4())    modules=uuid
    Set Suite Variable    ${uuid}

Generate Email Id
    [Documentation]    Generate random email id
    ${first_name}=    Set Variable    QATest
    ${last_name}    Generate random string    4    abcdefghijklmnopqrstuvwxyz  
    ${com}=     Set variable    @mailinator.com
    ${email}=   Set variable    ${first_name}${last_name}${com}
    Set Suite Variable    ${email}
    Set Suite Variable    ${first_name}
    Set Suite Variable    ${last_name}
    RETURN    ${email}

Generate Phone Number
    [Documentation]    Generate random phone number
    ${ph_Number_1}    Generate random string    5    98765
    ${ph_Number_2}    Generate random string    5    0123456789
    ${phone}=    Set variable   ${ph_Number_1}${ph_Number_2}
    RETURN    ${phone}
