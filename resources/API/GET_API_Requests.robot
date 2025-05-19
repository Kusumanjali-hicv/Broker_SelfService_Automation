*** Settings ***
Resource    ${EXECDIR}/resources/master.robot
Library     DateTime

*** Variables ***
${ACCESS_TOKEN}
${destination}
${campaignId}
${checkIn_date}  
${checkOut_date}
${lengthOfStay}
${tourDate}
${tourWaveAllotmentId} 
${propertyCodes}

*** Keywords ***
Get Checkin Checkout Date
    [Documentation]    Get checkin date
    ${checkIn_date}=    Get Current Date    result_format=%Y-%m-%d
    #add 7days to the current date
    ${checkIn_date}=    Add Time To Date    ${checkIn_date}    7 days    result_format=%Y-%m-%d
    
    ${checkOut_date}=    Add Time To Date    ${checkIn_date}    ${lengthOfStay} days    result_format=%Y-%m-%d
    
    Set Suite Variable    ${checkIn_date}
    Set Suite Variable    ${checkOut_date}


GET Tour Allotments
    [Documentation]    GET Tours Allotments Details
    ${ACCESS_TOKEN}=    GET Access Token
    ${headers}    Create Dictionary
    ...    ${X_ENV_NAME}=${X_ENV_VALUE}
    ...    ${AUTHORIZATION_NAME}=Bearer ${ACCESS_TOKEN}

    ${query_params}    Create Dictionary
    ...    campaignId=${campaignId}
    ...    destination=${destination}
    ...    checkIn=${checkIn_date}
    ...    checkOut=${checkOut_date}

    Create Session    Session    ${BASE_URL}    headers=${headers}    verify=true
    ${RESPONSE}    GET On Session    Session    ${TOUR_ALLOTMENT_URL}    params=${query_params}
    Should Be Equal As Strings    ${RESPONSE.status_code}    200
    #parse the response & get the first allotments which is not empty & 
    ${json}=    Set Variable    ${RESPONSE.json()}
    FOR    ${item}    IN    @{json}
        ${allotments}=    Set Variable    ${item['allotments']}
        IF    ${allotments}
            Set Suite Variable    ${tourDate}    ${item['date']}
            Set Suite Variable    ${tourWaveAllotmentId}    ${allotments}[0][tourWaveAllotmentId]    
            Set Suite Variable    ${propertyCodes}           ${allotments}[0][locationCode] 
            Exit For Loop
        END
    END
    

GET Packages
    [Documentation]    Get Packages and select a random package ID
    ${ACCESS_TOKEN}=    GET Access Token
    ${headers}    Create Dictionary
    ...    ${X_ENV_NAME}=${X_ENV_VALUE}
    ...    ${AUTHORIZATION_NAME}=Bearer ${ACCESS_TOKEN}

    Create Session    Session    ${BASE_URL}    headers=${headers}    verify=true
    ${RESPONSE}    GET On Session    Session    ${PACKAGES_URL}
    Should Be Equal As Strings    ${RESPONSE.status_code}    200
    ${json}=    Set Variable    ${RESPONSE.json()}
    
    # Get total number of packages
    ${package_count}=    Get Length    ${json}
    # Generate random index
    ${random_index}=    Evaluate    random.randint(0, ${package_count}-1)    random
    # Get random package ID
    ${packageId}=    Set Variable    ${json}[${random_index}][packageId]
    Set Suite Variable    ${packageId}    ${packageId}


GET Reservation Availabilities
    [Documentation]    Get Reservation Availabilities

    ${ACCESS_TOKEN}=    GET Access Token
    ${headers}    Create Dictionary
    ...    ${X_ENV_NAME}=${X_ENV_VALUE}
    ...    ${AUTHORIZATION_NAME}=Bearer ${ACCESS_TOKEN}

    ${query_params}    Create Dictionary
    ...    checkInFrom=${checkIn_date}
    ...    checkInTo=${checkOut_date}
    ...    isSummary=false
    ...    lengthOfStay=${lengthOfStay}
    ...    campaignId=${campaignId}
    ...    propertyCodes=dislb    #${propertyCodes}
    ...    destination=${destination}
    ...    reservationType=Marketing
    ...    reservationSubType=Mini Vac            #Events

    #${URL}    Set Variable    https://apirtf.orangelake.com

    Create Session    Session    ${BASE_URL}    headers=${headers}    verify=true
    ${RESPONSE}    GET On Session    Session    ${RESERVATION_AVAILABILITY_URL}    params=${query_params}
    
    Should Be Equal As Strings    ${RESPONSE.status_code}    200
    
    ${json}=    Set Variable    ${RESPONSE.json()}

    # Extract propertyCode from the first property
    ${propertyCode}=    Set Variable    ${json[0]['propertyCode']}
    Set Suite Variable    ${propertyCode}    ${propertyCode}

    # Extract propertyRoomTypeId and roomTypeCode from the first roomType
    ${propertyRoomTypeId}=    Set Variable    ${json[0]['roomTypes'][0]['propertyRoomTypeId']}
    Set Suite Variable    ${propertyRoomTypeId}    ${propertyRoomTypeId}
    ${roomTypeCode}=    Set Variable    ${json[0]['roomTypes'][0]['roomTypeCode']}
    Set Suite Variable    ${roomTypeCode}    ${roomTypeCode}

    # Extract inventories (inventoryId & dateAvailable) from the first roomType's periods
    ${periods}=    Set Variable    ${json[0]['roomTypes'][0]['periods']}
    ${inventories}=    Create List
    FOR    ${period}    IN    @{periods}
        FOR    ${inventory}    IN    @{period}[inventories]
            ${inv}=    Create Dictionary    inventoryId=${inventory}[inventoryId]    night=${inventory}[dateAvailable]
            Append To List    ${inventories}    ${inv}
        END
    END
    # Check inventories is not empty
    Should Not Be Empty    ${inventories}
    Set Suite Variable    ${inventories}    ${inventories}

    # Extract allInventories (inventoryId & night) from all roomTypes of all properties
    ${allInventories}=    Create List
    FOR    ${property}    IN    @{json}
        FOR    ${roomType}    IN    @{property}[roomTypes]
            FOR    ${period}    IN    @{roomType}[periods]
                FOR    ${inventory}    IN    @{period}[inventories]
                    ${inv}=    Create Dictionary    inventoryId=${inventory}[inventoryId]    night=${inventory}[dateAvailable]
                    Append To List    ${allInventories}    ${inv}
                END
            END
        END
    END
    
    #Set Suite Variable    ${allInventories}    ${allInventories}