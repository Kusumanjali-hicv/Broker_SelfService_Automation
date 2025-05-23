*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    JSONLibrary
Resource    ${EXECDIR}/resources/master.robot

*** Variables ***
&{DEFAULT_HEADERS}    
...    ${X_ENV_NAME}=${X_ENV_VALUE}
...    Accept=${CONTENT_TYPE_HEADER_VALUE}
${json_file_path}    ${EXECDIR}/json/ 
${email}
${phone_number}
${marital_status}
${packageId}
${contact_id}    
${propertyCode}      
${propertyRoomTypeId}    
${roomTypeCode}        
${inventories}    
${opportunityId}
${uuid}
${SUCCESS_STATUS}    Success
${DEFAULT_STATUS_CODE}    200
${ACCEPTED_STATUS_CODE}    202

*** Keywords ***
Create API Session With Auth
    [Arguments]    ${token}=${ACCESS_TOKEN}
    ${headers}=    Copy Dictionary    ${DEFAULT_HEADERS}
    Set To Dictionary    ${headers}    ${AUTHORIZATION_NAME}=Bearer ${token}
    Create Session    Session    ${BASE_URL}    headers=${headers}    verify=true
    RETURN    Session

Send Credit Eligibility Request
    [Documentation]    POST Credit Eligibility
    [Arguments]    ${vendor}   
    Create API Session With Auth
    
    ${json_body}=    Load JSON From File    ${json_file_path}${CREDIT_ELIGIBILITY}
    Set To Dictionary    ${json_body}
    ...    email=${email}
    ...    phoneNumber=${phone_number}
    ...    firstName=${first_name}
    ...    lastName=${last_name}
    ...    maritalStatus=${marital_status}

    ${response}=    POST On Session    Session    ${CREDIT_ELIGIBILITY_URL}    json=${json_body}    expected_status=any 
    Run Keyword If    '${response.status_code}'!='${DEFAULT_STATUS_CODE}'
    ...    Fail    Credit Eligibility request failed with status code: ${response.status_code} and error: ${response.text}
    
    ${json_object}=    Evaluate    json.loads('''${response.text}''')    json
    ${contact_id}=    Get Value From Json    ${json_object}    $.contactId
    ${actual_message}=    Get From Dictionary    ${json_object}    status

    Should Be Equal As Strings    '${response.status_code}'    '${DEFAULT_STATUS_CODE}'
    Should Be Equal As Strings    '${actual_message}'    '${SUCCESS_STATUS}'
    
    ${contact_value}=    Set Variable If    ${contact_id} and len($contact_id) > 0    ${contact_id}[0]    ${None}
    RETURN    ${contact_value}

Send Tour Booking Request
    [Documentation]    POST Tour Bookings
    Create API Session With Auth

    ${JSON_BODY}=    Load JSON From File   ${json_file_path}${TOUR_BOOKING}
    Set To Dictionary    ${JSON_BODY}
    ...    campaignId=${campaignId}
    ...    contactId=${contact_id}  
    ...    packageId=${packageId}  
    ...    tourDate=${tourDate}
    ...    tourWaveAllotmentId=${tourWaveAllotmentId}

    ${response}=    POST On Session    Session    ${TOURS_BOOKING_URL}    json=${json_body}
    Should Be True    ${response.status_code} in [201, 202]
    ...    Expected status code to be 201 or 202, but got ${response.status_code}

Send Reservation Request
    [Documentation]    POST Reservations Bookings
    Create API Session With Auth

    ${json_body}=    Load JSON From File    ${json_file_path}${RESERVATION_BOOKING}
    ${reservation_request}=    Create Reservation Request Body

    Set To Dictionary    ${json_body}    
    ...    campaignId=${campaignId}
    ...    tourWaveAllotmentId=${tourWaveAllotmentId}
    ...    packageProductId=${packageId}
    ...    contactId=${contact_id}
    ...    destination=${destination}
    ...    primaryPreferredArrivalDate=${checkIn_date}
    ...    reservationRequest=${reservation_request}

    ${response}=    POST On Session    Session    ${RESERVATION_BOOKING_URL}    json=${json_body}
    Handle Reservation Response    ${response}

Create Reservation Request Body
    ${lengthOfStay_int}=    Convert To Integer    ${lengthOfStay}
    ${numberOfGuests_int}=    Convert To Integer    ${numberOfGuests}
    
    &{reservation_request}=    Create Dictionary
    ...    checkin=${checkIn_date}
    ...    checkout=${checkOut_date}
    ...    lengthOfStay=${lengthOfStay_int}
    ...    numberOfGuests=${numberOfGuests_int}
    ...    propertyCode=${propertyCode}
    ...    propertyRoomTypeId=${propertyRoomTypeId}
    ...    roomTypeCode=${roomTypeCode}
    ...    inventories=${inventories}
    RETURN    ${reservation_request}

Handle Reservation Response
    [Arguments]    ${response}
    IF    '${response.status_code}' == '${ACCEPTED_STATUS_CODE}'
        ${opportunity_id}=    Get From Dictionary    ${response.json()}    opportunityId
        ${reservationRequestId}=    Get From Dictionary    ${response.json()}    reservationRequestId
        ${tourRequestId}=    Get From Dictionary    ${response.json()}    tourRequestId
        ${message}=    Get From Dictionary    ${response.json()}    message   
        Should Be Equal As Strings    ${message}    Your Stay has been created.
        Set Suite Variable    ${opportunityId}    ${opportunity_id}
        Set Suite Variable    ${reservationRequestId}    ${reservationRequestId}
        Set Suite Variable    ${tourRequestId}    ${tourRequestId}
    ELSE
        Log    *HTML* <font color="red">Reservation Failed with Status Code: ${response.status_code}</font>    level=ERROR
        Log    *HTML* <font color="red">Error Response: ${response.text}</font>    level=ERROR
        Fail    Reservation request failed
    END

Cancel Reservation Booking
    [Documentation]    Cancel an existing reservation
    ${headers}=    Create Dictionary    x-correlation-id=${X_ENV_VALUE}-${uuid}
    Create Session    Session    ${BASE_URL}    headers=${headers}    verify=true

    ${response}=    DELETE On Session    Session    ${CANCEL_RESERVATION_URL}${opportunityId}
    
    ${json}=    Set Variable    ${response.json()}
    Run Keyword If    '${response.status_code}' == '${ACCEPTED_STATUS_CODE}'
    ...    Verify Cancellation Success    ${json}
    ...    ELSE
    ...    Handle Cancellation Failure    ${response.status_code}    ${json}

Verify Cancellation Success
    [Arguments]    ${json}
    ${status}=    Get From Dictionary    ${json}    status
    ${message}=    Get From Dictionary    ${json}    message
    Should Be Equal As Strings    ${status}    ${SUCCESS_STATUS}
    Should Be Equal As Strings    ${message}    Reservation Cancelled Successfully

Handle Cancellation Failure
    [Arguments]    ${status_code}    ${json}
    Log    *HTML* <font color="red">Cancellation Request Failed with Status Code: ${status_code}</font>    level=ERROR
    Log    *HTML* <font color="red">Error Response: ${json}</font>    level=ERROR
    Fail    Reservation Cancel request failed
