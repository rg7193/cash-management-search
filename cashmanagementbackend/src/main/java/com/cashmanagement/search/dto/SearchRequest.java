package com.cashmanagement.search.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class SearchRequest {
    private String query;
    private Integer page = 0;
    private Integer size = 10;
    private Boolean includePayments = true;
    private Boolean includeDeposits = true;
    private Boolean includeLoans = true;
}
