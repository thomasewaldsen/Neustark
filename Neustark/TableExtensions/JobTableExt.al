tableextension 50105 JobTableExt extends Job
{
    fields
    {
        field(50100; Bestellungen; Decimal)
        {
            AccessByPermission = TableData "Purch. Rcpt. Header" = R;
            CalcFormula = Sum("Purchase Header".SenQty WHERE(NewJobNo = FIELD("No.")));
            Caption = 'Bestellungen';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
    }

    var
        myInt: Integer;
}