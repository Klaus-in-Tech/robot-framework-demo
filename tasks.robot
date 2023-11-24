*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.

Library    RPA.Browser.Selenium    auto_close=${False}
Library    RPA.HTTP
Library    RPA.Tables 
Library    RPA.Desktop
Library    RPA.PDF
Library    RPA.Archive


*** Variables ***
${URL}=    https://robotsparebinindustries.com/
${DOWNLOADURL}=       https://robotsparebinindustries.com/orders.csv
${currdir}=    D:\\_PROJECTS\\Robocorp projects\\robot-framework-demo\\
${data}
${delay}=    10 sec
${receiptpath}=    output${/}receipts
${screenshotpath}=    output${/}screenshots
${mergedpath}=    output${/}merged
${FILE_TO_BE_ZIPPED}=    D:\\_PROJECTS\\Robocorp projects\\robot-framework-demo\\output\\merged


*** Tasks ***
#Open the intranet site and log in
    # Open the intranet website
    # Log in
    # Close the annoying modal
    # Get orders
    # Fill the forms and submit order

Create zipped file
    Create ZIP package for the merged file

    



*** Keywords ***
Open the intranet website
    Open Available Browser    ${URL}
    Maximize Browser Window

Log in
    Input Text    username    maria
    Input Password    password    thoushallnotpass
    Submit Form

Get orders
    Download     
    ...    ${DOWNLOADURL}    
    ...    overwrite=${True}

Read CSV File
    ${data}=    Read table from CSV   path=${currdir}orders.csv    
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
    Wait Until Keyword Succeeds    5x    20s    Click Button    //*[@id="order"]
    Wait Until Page Contains Element    id:order-another    timeout=20s
    ${pdf}=    Store the receipt as a PDF file    ${row}[Order number]
    ${screenshot}=    Take a screenshot of the robot    ${row}[Order number]
    Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}    ${row}[Order number]
    Reload Page
    Wait Until Keyword Succeeds    5x    20s    Go To    https://robotsparebinindustries.com/#/robot-order
    Wait Until Page Contains Element    css:div.modal-body    timeout=10s
    Click Button    //*[@id="root"]/div/div[2]/div/div/div/div/div/button[1]
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
    Log        Receipt with path ${OUTPUT_DIR}${/}${receipt}${/}receipt-${orderNumber}.pdf processed.
    Log To Console    Receipt with path ${OUTPUT_DIR}${/}${receipt}${/}receipt-${orderNumber}.pdf processed.
    [Return]   ${OUTPUT_DIR}${/}${receiptpath}${/}receipt-${orderNumber}.pdf

Take a screenshot of the robot
    [Arguments]    ${orderNumber}
    ${screenshot}=    Screenshot    id:robot-preview-image     ${OUTPUT_DIR}${/}${screenshotpath}${/}robot-${orderNumber}.png
    Log    Screenshot with ${OUTPUT_DIR}${/}${screenshotpath}${/}robot-${orderNumber}.png processed.
    Log To Console    Screenshot with ${OUTPUT_DIR}${/}${screenshotpath}${/}robot-${orderNumber}.png processed.
    [Return]    ${screenshot}

Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${screenshot}    ${pdf}    ${orderNumber}
    Open Pdf    ${pdf}
    Add Watermark Image To Pdf    ${screenshot}    ${OUTPUT_DIR}${/}${mergedpath}${/}merged-${orderNumber}.pdf    ${pdf}
    Close Pdf
    Log    ${pdf} and ${screenshot} merged.
    Log To Console    ${pdf} and ${screenshot} merged. 

Create ZIP package for the merged file
    ${zip_file_name}=    Set Variable    ${OUTPUT_DIR}${/}output${/}merged-receipts.zip
    Archive Folder With Zip    ${FILE_TO_BE_ZIPPED}    ${zip_file_name}
