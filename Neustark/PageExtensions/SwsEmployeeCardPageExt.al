pageextension 50116 SwsEmployeeCardPageExt extends "SwS Employee Card"
{
    layout
    {
        addafter(EmployeeNo)
        {
            field(VendorNo; Rec.VendorNo)
            {
                ApplicationArea = All;
                Editable = false;
                DrillDown = true;
                DrillDownPageId = 26;

                trigger OnDrillDown()
                var
                    VendorRec: Record Vendor;
                begin
                    if VendorRec.Get(Rec.VendorNo) then
                        Page.RunModal(26, VendorRec);
                end;
            }
        }
    }

    actions
    {
        addafter(CopyEmployee)
        {
            action(CreateVendor)
            {
                ApplicationArea = All;
                Caption = 'Kred. anlegen';
                Image = VendorContact;

                trigger OnAction()
                var
                    VendorRec: Record Vendor;
                    VendorBankAccRec: Record "Vendor Bank Account";
                    SwsEmployeeBankRec: Record "SwS Employee Bank";
                    IsExecuteCreateNewVendor: Boolean;
                    errorString: Text[2048];
                    SwsDepartementRec: Record "SwS Department";
                    SwsSupervisorRec: Record "SwS Department Supervisor";
                    VendorSupervisorRec2: Record Vendor;
                begin
                    // check if vendor exists

                    // create new vendor
                    IsExecuteCreateNewVendor := true;

                    if (Rec.Name = '') then begin
                        errorString += 'Name muss ausgefüllt sein';
                        IsExecuteCreateNewVendor := false;
                    end;

                    if (Rec.Address = '') then begin
                        errorString += '\Adresse muss ausgefüllt sein';
                        IsExecuteCreateNewVendor := false;
                    end;

                    if (Rec."Post Code" = '') then begin
                        errorString += '\PLZ muss ausgefüllt sein';
                        IsExecuteCreateNewVendor := false;
                    end;

                    if (Rec.City = '') then begin
                        errorString += '\Ort muss ausgefüllt sein';
                        IsExecuteCreateNewVendor := false;
                    end;

                    if (Rec."Language Code" = '') then begin
                        errorString += '\Sprachcode muss ausgefüllt sein';
                        IsExecuteCreateNewVendor := false;
                    end;
                    if (not IsExecuteCreateNewVendor) then
                        Message(errorString);

                    if (IsExecuteCreateNewVendor) then begin
                        if (Rec.VendorNo = '') then begin
                            // check If vendor was created manually -> if yes update Rec.VendorNo
                            VendorRec.SetRange("E-Mail", Rec."Business E-Mail");
                            if VendorRec.FindFirst() then begin
                                Rec.VendorNo := VendorRec."No.";
                                VendorRec.SwsEmployeeNo := Rec."Employee No.";
                            end
                            else begin
                                VendorRec.Init();

                                VendorRec.Validate(Name, Rec.Name);
                                VendorRec.Validate("Name 2", Rec."First Name");
                                VendorRec.Validate("Search Name", Rec."First Name" + ' ' + Rec.Name);
                                VendorRec.Validate("E-Mail", Rec."Business E-Mail");
                                VendorRec.Validate("Expenses ASER", true);
                                VendorRec.Validate("Gen. Bus. Posting Group", 'INLAND');
                                VendorRec.Validate("VAT Bus. Posting Group", 'INLAND');
                                VendorRec.Validate("Vendor Posting Group", 'INLAND');

                                // // get departement & supervisor
                                // if SwsDepartementRec.Get(Rec.Department) then begin
                                //     SwsSupervisorRec.SetRange("Department Code", SwsDepartementRec.Code);
                                //     if SwsSupervisorRec.FindFirst() then begin
                                //         // get vendor for supervisor
                                //         VendorSupervisorRec2.SetRange(SwsEmployeeNo, SwsSupervisorRec."Employee No.");
                                //         if VendorSupervisorRec2.FindFirst() then
                                //             VendorRec.Validate("Manager No. ASER", VendorSupervisorRec2."No.");
                                //     end;
                                // end;

                                VendorRec.Validate(Address, Rec.Address);
                                VendorRec.Validate("Address 2", Rec."Address 2");
                                VendorRec.Validate(City, Rec.City);
                                VendorRec.Validate("Post Code", Rec."Post Code");
                                VendorRec.Validate("Language Code", Rec."Language Code");
                                VendorRec.Validate("Application Method", "Application Method"::Manual);
                                VendorRec.Validate("Payment Terms Code", 'SOFORT');
                                VendorRec.Validate("Payment Method Code", 'UBS CHF');
                                VendorRec.SwsEmployeeNo := Rec."Employee No.";
                            end;
                        end;
                        if (Rec.VendorNo <> '') then begin
                            VendorRec.SetRange("No.", Rec.VendorNo);
                            if VendorRec.FindFirst() then begin
                                VendorRec.Validate(Name, Rec.Name);
                                VendorRec.Validate("Name 2", Rec."First Name");
                                VendorRec.Validate("Search Name", Rec."First Name" + ' ' + Rec.Name);
                                VendorRec.Validate("E-Mail", Rec."Business E-Mail");

                                // // get departement & supervisor
                                // if SwsDepartementRec.Get(Rec.Department) then begin
                                //     SwsSupervisorRec.SetRange("Department Code", SwsDepartementRec.Code);
                                //     if SwsSupervisorRec.FindFirst() then begin
                                //         // get vendor for supervisor
                                //         VendorSupervisorRec2.SetRange(SwsEmployeeNo, SwsSupervisorRec."Employee No.");
                                //         if VendorSupervisorRec2.FindFirst() then
                                //             VendorRec.Validate("Manager No. ASER", VendorSupervisorRec2."No.");
                                //     end;
                                // end;

                                VendorRec.Validate(Address, Rec.Address);
                                VendorRec.Validate("Address 2", Rec."Address 2");
                                VendorRec.Validate(City, Rec.City);
                                VendorRec.Validate("Post Code", Rec."Post Code");
                                VendorRec.Validate("Language Code", Rec."Language Code");
                                VendorRec.Validate("Application Method", "Application Method"::Manual);
                                VendorRec.Validate("Payment Terms Code", 'SOFORT');
                                VendorRec.Validate("Payment Method Code", 'UBS CHF');
                                VendorRec.SwsEmployeeNo := Rec."Employee No.";
                            end;
                        end
                        else
                            if (Rec.VendorNo = '') then begin
                                VendorRec.Insert(true);
                                Rec.VendorNo := VendorRec."No.";
                            end;
                    end;


                    // get sws employee bank acc
                    // check if update/new
                    SwsEmployeeBankRec.SetRange("Employee No.", Rec."Employee No.");
                    if SwsEmployeeBankRec.FindFirst() then begin
                        // create bank acc for vendor
                        if not VendorBankAccRec.Get(VendorRec."No.", 'IBAN') then
                            VendorBankAccRec.Init();
                        VendorBankAccRec.Validate(Code, 'IBAN');
                        VendorBankAccRec.Validate("Vendor No.", VendorRec."No.");
                        VendorBankAccRec.Validate("Payment Form", VendorBankAccRec."Payment Form"::"Bank Payment Domestic");
                        VendorBankAccRec.Validate("SWIFT Code", SwsEmployeeBankRec."BIC (SWIFT)");
                        VendorBankAccRec.Validate(IBAN, SwsEmployeeBankRec.IBAN);
                        if not VendorBankAccRec.Get(VendorRec."No.", 'IBAN') then
                            VendorBankAccRec.Insert(true)
                        else
                            VendorBankAccRec.Modify();

                        VendorRec.Validate("Preferred Bank Account Code", 'IBAN');
                        VendorRec.Modify();
                    end;
                end;
            }
        }
    }

    var
        myInt: Integer;
}