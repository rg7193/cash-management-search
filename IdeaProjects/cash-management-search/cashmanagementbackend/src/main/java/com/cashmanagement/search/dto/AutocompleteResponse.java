package com.cashmanagement.search.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class AutocompleteResponse {
    private List<AutocompleteSuggestion> suggestions;
    private String originalQuery;
    
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class AutocompleteSuggestion {
        private String suggestion;
        private String source;
    }
}
