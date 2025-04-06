package com.cashmanagement.search.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class SearchResultDTO {
    private String entityType;
    private Long entityId;
    private String primaryIdentifier;
    private LocalDateTime date;
    private BigDecimal amount;
    private String currency;
    private String status;
    private String partyInfo;
    private String description;
    private String referenceNumber;
    private Float rank;
}
