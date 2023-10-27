tableextension 50104 CompanyInformationTableExt extends "Company Information"
{
    fields
    {
        field(50100; "Sen Language Code"; Code[10])
        {
            Caption = 'Language Code';
            TableRelation = Language;
        }
    }
}