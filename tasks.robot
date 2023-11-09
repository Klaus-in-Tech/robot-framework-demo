*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.

Library            RPA.Browser.Selenium


*** Variables ***
${URL}=     https://robotsparebinindustries.com/


*** Tasks ***
Open the intranet site and log in
    Open the intranet website
    Log in


*** Keywords ***
Open the intranet website
    Open Available Browser    ${URL}

Log in
    Input Text    username    maria
    Input Password    password    thoushallnotpass
    Submit Form