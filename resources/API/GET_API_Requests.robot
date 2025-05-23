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
    [Arguments]    ${property_type}
    ${headers}=    Create API Headers
    ${query_params}=    Create Dictionary
    ...    checkInFrom=${checkIn_date}
    ...    checkInTo=${checkOut_date}
    ...    isSummary=false
    ...    lengthOfStay=${lengthOfStay}
    ...    campaignId=${campaignId}
    #...    propertyCodes=dislb
    ...    destination=${destination}
    ...    reservationType=Marketing
    ...    reservationSubType=Mini Vac

    Initialize API Session    ${headers}
    ${response}=    GET On Session    Session    ${RESERVATION_AVAILABILITY_URL}    params=${query_params}
    Should Be Equal As Strings    ${response.status_code}    200
    
    ${json}=    Set Variable    ${response.json()}
    Parse Reservation Response    ${json}    ${property_type}

Parse Reservation Response
    [Arguments]    ${json}    ${property_type}
    IF    $property_type == "hotel"
        ${isResort}=    Set Variable    False
    ELSE IF    $property_type == "resort"
        ${isResort}=    Set Variable    True        
    END
    
    ${matching_property}=    Set Variable    ${None}
    ${matching_room_type}=    Set Variable    ${None}
    
    FOR    ${property}    IN    @{json}
        IF    ${property}[isResort] == ${isResort}
            ${matching_property}=    Set Variable    ${property}
            ${matching_room_type}=    Set Variable    ${property}[roomTypes][0]
            Exit For Loop
        END
    END
    
    Should Not Be Equal    ${matching_property}    ${None}    No property found with isResort=${isResort}
    ${property}=    Set Variable    ${matching_property}
    ${room_type}=    Set Variable    ${matching_room_type}
    
    Set Suite Variable    ${propertyCode}    ${property}[propertyCode]
    Set Suite Variable    ${propertyRoomTypeId}    ${room_type}[propertyRoomTypeId]
    Set Suite Variable    ${roomTypeCode}    ${room_type}[roomTypeCode]
    
    ${inventories}=    Extract Inventories    ${room_type}[periods]
    Set Suite Variable    ${inventories}    ${inventories}

Extract Inventories
    [Arguments]    ${periods}
    ${inventories}=    Create List
    ${first_period}=    Set Variable    ${periods}[0]
    
    Set Suite Variable    ${checkIn_date}    ${first_period}[firstNight]
    #add one day to checkOut_date
    ${checkOut_date}=    Set Variable   ${first_period}[lastNight]    
    ${checkOut_date}=    Add Time To Date    ${checkOut_date}    1 days    result_format=%Y-%m-%d
    Set Suite Variable    ${checkOut_date}   ${checkOut_date}

    ${length_of_stay}=     Subtract Date From Date    ${checkOut_date}    ${checkIn_date}     verbose

    ${SF_checkIn_date}=    Convert Date    ${checkIn_date}    result_format=%m/%d/%Y
    ${SF_checkOut_date}=    Convert Date    ${checkOut_date}    result_format=%m/%d/%Y
    Set Suite Variable    ${SF_checkIn_date}
    Set Suite Variable    ${SF_checkOut_date}
    ${count}    Set Variable    0
    IF    "inventories" in ${first_period}
        FOR    ${inventory}    IN    @{first_period}[inventories]
            ${inv}=    Create Dictionary    night=${inventory}[dateAvailable]
            ${count}=    Evaluate    ${count}+1
            IF    "inventoryId" in ${inventory}
                Set To Dictionary    ${inv}    inventoryId=${inventory}[inventoryId]
            END
            Append To List    ${inventories}    ${inv}
        END
    END
    
    Should Not Be Empty    ${inventories}
    ${length_of_stay}=    Set Variable    ${count}
    RETURN    ${inventories}

GET Campaign Id
    [Documentation]    Get Campaign Id
    [Arguments]    ${vendor}
    ${headers}=    Create API Headers
    Initialize API Session    ${headers}
    ${response}=    GET On Session    Session    ${CAMPAIGN_ID_URL}${vendor}
    Should Be Equal As Strings    ${response.status_code}    200
    
    ${json}=    Set Variable    ${response.json()}
    Set Suite Variable    ${campaignId}    ${json}[0][campaignId]
