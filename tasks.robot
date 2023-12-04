*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.

Library    RPA.Browser.Selenium
Library    RPA.HTTP
Library    RPA.Tables 
Library    RPA.Desktop
Library    RPA.PDF
Library    RPA.Archive
Library    RPA.RobotLogListener
Library    RPA.Robocloud.Secrets


*** Variables ***
${URL}=    https://robotsparebinindustries.com/
${DOWNLOAD_URL}=       https://robotsparebinindustries.com/orders.csv
${GLOBAL_RETRY_INTERVAL}=    2s
${GLOBAL_RETRY_AMOUNT}=    10x
${receiptpath}=    receipts
${screenshotpath}=    screenshots
${mergedpath}=    merged
${FILE_TO_BE_ZIPPED}=    ${OUTPUT_DIR}${/}${mergedpath}
${ORDER_CSV}=    ${OUTPUT_DIR}${/}orders.csv


*** Tasks ***
Open the intranet site and log in
    Open the intranet website
    Log in
    Close the annoying modal

Create orders
    Get orders
    Fill the forms and submit order

Create zipped file for the merged receipts
    Create ZIP package for the merged file

    



*** Keywords ***
Open the intranet website
    Open Available Browser    ${URL}
    Maximize Browser Window

Log in
    ${secret}    Get Secret    ROBOT_CREDENTIALS
    Input Text    username    ${secret}[username]
    Input Password    password    ${secret}[password]
    Submit Form

Get orders
    Download     
    ...    ${DOWNLOAD_URL}
    ...    target_file=${ORDER_CSV} 
    ...    overwrite=${True}

Read CSV File
    ${data}=    Read table from CSV   path=${OUTPUT_DIR}${/}orders.csv    
    FOR    ${row}    IN    @{data}
        Log    ${row}
    END
    RETURN    ${data}
    
Close the annoying modal
    Go To    https://robotsparebinindustries.com/#/robot-order
    Click Button    //*[@id="root"]/div/div[2]/div/div/div/div/div/button[1]

Fill the form
    [Arguments]    ${row}
    Select From List By Value    head    ${row}[Head]
    Click Element    id:id-body-${row}[Body]
    Input Text    css:div>input    ${row}[Legs]
    Input Text    address    ${row}[Address]
    Wait Until Keyword Succeeds    ${GLOBAL_RETRY_AMOUNT}    ${GLOBAL_RETRY_INTERVAL}    Submit the order
    ${pdf}=    Store the receipt as a PDF file    ${row}[Order number]
    ${screenshot}=    Take a screenshot of the robot    ${row}[Order number]
    Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}    ${row}[Order number]
    Wait Until Keyword Succeeds    ${GLOBAL_RETRY_AMOUNT}    ${GLOBAL_RETRY_INTERVAL}    Go to order another robot
    Close the annoying modal
    Log    Order number ${row}[Order number] processed.
    Log To Console    Order number ${row}[Order number] processed.

    
Fill the forms and submit order
    ${data}=    Read CSV File
    FOR    ${row}    IN    @{data}
        Run Keyword And Continue On Failure    Fill the form    ${row}
    END

Store the receipt as a PDF file
    [Arguments]    ${orderNumber}    
    ${receipt}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${receipt}    ${OUTPUT_DIR}${/}${receiptpath}${/}receipt-${orderNumber}.pdf
    Log        Receipt with path ${OUTPUT_DIR}${/}${receiptpath}${/}receipt-${orderNumber}.pdf processed.
    Log To Console    Receipt with path ${OUTPUT_DIR}${/}${receiptpath}${/}receipt-${orderNumber}.pdf processed.
    [Return]   ${OUTPUT_DIR}${/}${receiptpath}${/}receipt-${orderNumber}.pdf

Take a screenshot of the robot
    [Arguments]    ${orderNumber}
    ${screenshot}=    Screenshot    id:robot-preview-image     ${OUTPUT_DIR}${/}${screenshotpath}${/}robot-${orderNumber}.png
    Log    Screenshot with path ${OUTPUT_DIR}${/}${screenshotpath}${/}robot-${orderNumber}.png processed.
    Log To Console    Screenshot with path ${OUTPUT_DIR}${/}${screenshotpath}${/}robot-${orderNumber}.png processed.
    [Return]    ${screenshot}

Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${screenshot}    ${pdf}    ${orderNumber}
    Open Pdf    ${pdf}
    Add Watermark Image To Pdf    ${screenshot}    ${OUTPUT_DIR}${/}${mergedpath}${/}merged-${orderNumber}.pdf    ${pdf}
    Close Pdf
    Log    ${pdf} and ${screenshot} merged sucessfully.
    Log To Console    ${pdf} and ${screenshot} merged successfully. 

Create ZIP package for the merged file
    ${zip_file_name}=    Set Variable    ${OUTPUT_DIR}${/}merged-receipts.zip
    Archive Folder With Zip    ${FILE_TO_BE_ZIPPED}    ${zip_file_name}

Submit the order
    ${btn_order}    Set Variable    //*[@id="order"]
    ${receipt}    Set Variable  //*[@id="receipt"]

    Mute Run On Failure    Page Should Contain Element 

    Click button                    ${btn_order}
    Page Should Contain Element     ${receipt}

Go to order another robot
    Set Local Variable      ${btn_order_another_robot}      //*[@id="order-another"]
    Click Button            ${btn_order_another_robot}

