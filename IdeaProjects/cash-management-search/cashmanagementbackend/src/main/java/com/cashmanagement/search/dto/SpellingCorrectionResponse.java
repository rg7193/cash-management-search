package com.cashmanagement.search.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class SpellingCorrectionResponse {
    private List<SpellingSuggestion> suggestions;
    private String originalQuery;
    
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class SpellingSuggestion {
        private String suggestion;
        private Float similarity;
    }
}
