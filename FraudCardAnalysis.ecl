Layout := RECORD
    UNSIGNED2   ds_authorization_code;
    DECIMAL18_8  transaction_amount; 
    UNSIGNED2 ds_pos_entry_code; 
    UNSIGNED3   transaction_time;  
    STRING  merchant_category_code;
    STRING auth_type_id; INTEGER fraud; 
END;

finaltxnData:= DATASET('~dataseers::dataseers::inputfiles::codes::20230518_frauddataseeded',Layout,CSV(HEADING(1),QUOTE('"'),SEPARATOR(',')),OPT);

// Add a sequence id to each record.  IDs must be sequential from 1 to N (the number of records).
// Note: Macros do not return a result.  The result is placed into the attribute named by the second parameter.
HC.AddID(finaltxnData, MyDS2);
//output(MyDS2);

// Convert the data into a cell-based format that supports both textual and numeric data.
// Note that this macro also produces an attribute <output_attr>_fields (e.g. MyDSFinal_fields) that contains
// the field names in the correct order.
HC.ToAnyField(MyDS2, MyDSFinal);

output(MyDSFinal(id < 100));
categoricals:=['ds_authorization_code','auth_type_id','mechant_category_code','ds_pos_entry_code','isfraud'];

// Now load the data into a probability space:
prob := HC.Probability(MyDSFinal, MyDSFinal_fields, categoricals);

// At this point, you can request a summary of the loaded dataset, which shows the number of records loaded, 
// the fields, and the detected values for each field.

summary := prob.Summary();
//OUTPUT(summary, NAMED('DatasetSummary'));


viz := HC.viz;

queries := [
    'CORRELATION()',
    'dependence()',
    'p(fraud = 1 | auth_type_id)',
    'p(fraud = 1 | merchant_category_code)',
    'CMODEL(auth_type_id,transaction_amount,ds_authorization_code,ds_pos_entry_code,fraud|$power=8, $sensitivity=6, $depth=3)',
    'p(fraud = 1 | ds_pos_entry_code)',
    'p(fraud = 1 | ds_authorization_code)'
    ];  
viz.Plot(queries, prob.PS);


