*** Settings ***
Resource    ${EXECDIR}/resources/master.robot
Library    Collections
Library    DateTime

*** Variables ***
${ACCESS_TOKEN}
${propertyCode}
${checkIn_date}  
${checkOut_date}
${tourDate} 
${tourWaveAllotmentId}
${propertyCodes}
${packageId}
${propertyRoomTypeId}
${roomTypeCode}
${campaignId} 

*** Keywords ***
Create API Headers
    [Arguments]    ${token}=${ACCESS_TOKEN}
    ${token}=    Set Variable If    "${token}"=="${EMPTY}"    ${ACCESS_TOKEN}    ${token}
    ${headers}    Create Dictionary
    ...    ${X_ENV_NAME}=${X_ENV_VALUE}
    ...    ${AUTHORIZATION_NAME}=Bearer ${token}
    RETURN    ${headers}

Initialize API Session
    [Arguments]    ${headers}
    Create Session    Session    ${BASE_URL}    headers=${headers}    verify=true

GET Tour Allotments
    [Documentation]    GET Tours Allotments Details
    ${headers}=    Create API Headers    
    ${query_params}=    Create Dictionary
    ...    campaignId=${campaignId}
    ...    destination=${destination}
    ...    checkIn=${checkIn_date}
    ...    checkOut=${checkOut_date}

    Initialize API Session    ${headers}
    ${response}=    GET On Session    Session    ${TOUR_ALLOTMENT_URL}    params=${query_params}
    Should Be Equal As Strings    ${response.status_code}    200

    ${json}=    Set Variable    ${response.json()}
    FOR    ${item}    IN    @{json}
        ${allotments}=    Set Variable    ${item['allotments']}
        IF    ${allotments}
            Set Suite Variables From Allotment    ${item}    ${allotments}[0]
            Exit For Loop
        END
    END

Set Suite Variables From Allotment
    [Arguments]    ${item}    ${allotment}
    Set Suite Variable    ${tourDate}    ${item['date']}
    Set Suite Variable    ${tourWaveAllotmentId}    ${allotment}[tourWaveAllotmentId]    
    Set Suite Variable    ${propertyCodes}    ${allotment}[locationCode] 
    Set Suite Variable    ${destination}    ${allotment}[resortDestination]

GET Packages
    [Documentation]    Get Packages and select a random package ID
    ${headers}=    Create API Headers
    Initialize API Session    ${headers}
    ${response}=    GET On Session    Session    ${PACKAGES_URL}
    Should Be Equal As Strings    ${response.status_code}    200
    
    ${json}=    Set Variable    ${response.json()}
    ${random_index}=    Evaluate    random.randint(0, len($json)-1)    random
    Set Suite Variable    ${packageId}    ${json}[${random_index}][packageId]

GET Reservation Availabilities
    [Documentation]    Get Reservation Availabilities
    ${headers}=    Create API Headers
    ${query_params}=    Create Dictionary
    ...    checkInFrom=${checkIn_date}
    ...    checkInTo=${checkOut_date}
    ...    isSummary=false
    ...    lengthOfStay=${lengthOfStay}
    ...    campaignId=${campaignId}
    ...    propertyCodes=dislb
    ...    destination=${destination}
    ...    reservationType=Marketing
    ...    reservationSubType=Mini Vac

    Initialize API Session    ${headers}
    ${response}=    GET On Session    Session    ${RESERVATION_AVAILABILITY_URL}    params=${query_params}
    Should Be Equal As Strings    ${response.status_code}    200
    
    ${json}=    Set Variable    ${response.json()}
    Parse Reservation Response    ${json}

Parse Reservation Response
    [Arguments]    ${json}
    ${first_property}=    Set Variable    ${json}[0]
    ${first_room_type}=    Set Variable    ${first_property}[roomTypes][0]
    
    Set Suite Variable    ${propertyCode}    ${first_property}[propertyCode]
    Set Suite Variable    ${propertyRoomTypeId}    ${first_room_type}[propertyRoomTypeId]
    Set Suite Variable    ${roomTypeCode}    ${first_room_type}[roomTypeCode]
    
    ${inventories}=    Extract Inventories    ${first_room_type}[periods]
    Set Suite Variable    ${inventories}    ${inventories}

Extract Inventories
    [Arguments]    ${periods}
    ${inventories}=    Create List
    FOR    ${period}    IN    @{periods}
        ${has_inventories}=    Run Keyword And Return Status    Dictionary Should Contain Key    ${period}    inventories
        IF    ${has_inventories}
            FOR    ${inventory}    IN    @{period}[inventories]
                ${inv}=    Create Inventory Dictionary    ${inventory}
                Append To List    ${inventories}    ${inv}
            END
        END
    END
    Should Not Be Empty    ${inventories}
    RETURN    ${inventories}

Create Inventory Dictionary
    [Arguments]    ${inventory}
    ${has_inventory_id}=    Run Keyword And Return Status    Dictionary Should Contain Key    ${inventory}    inventoryId
    ${date_available}=    Set Variable    ${inventory}[dateAvailable]
    IF    ${has_inventory_id}
         ${inv}=    Create Dictionary    inventoryId=${inventory}[inventoryId]    night=${date_available}
    ELSE
         ${inv}=    Create Dictionary    inventoryId=null    night=${date_available}
    END
    RETURN    ${inv}

GET Campaign Id
    [Documentation]    Get Campaign Id
    [Arguments]    ${vendor}
    ${headers}=    Create API Headers
    Initialize API Session    ${headers}
    ${response}=    GET On Session    Session    ${CAMPAIGN_ID_URL}${vendor}
    Should Be Equal As Strings    ${response.status_code}    200
    
    ${json}=    Set Variable    ${response.json()}
    Set Suite Variable    ${campaignId}    ${json}[0][campaignId]
