package com.cashmanagement.search.service;

import com.cashmanagement.search.dto.AutocompleteResponse;
import com.cashmanagement.search.dto.SearchRequest;
import com.cashmanagement.search.dto.SearchResultDTO;
import com.cashmanagement.search.dto.SpellingCorrectionResponse;
import com.cashmanagement.search.repository.SearchRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class SearchService {

    private final SearchRepository searchRepository;
    
    public Page<SearchResultDTO> search(SearchRequest request) {
        Pageable pageable = PageRequest.of(request.getPage(), request.getSize());
        return searchRepository.fullTextSearch(request.getQuery(), pageable);
    }
    
    public AutocompleteResponse getAutocompleteSuggestions(String prefix, int limit) {
        List<AutocompleteResponse.AutocompleteSuggestion> suggestions = 
            searchRepository.getAutocompleteSuggestions(prefix, limit);
        
        return new AutocompleteResponse(suggestions, prefix);
    }
    
    public SpellingCorrectionResponse getSpellingSuggestions(String misspelledTerm, int limit) {
        List<SpellingCorrectionResponse.SpellingSuggestion> suggestions = 
            searchRepository.getSpellingSuggestions(misspelledTerm, limit);
        
        return new SpellingCorrectionResponse(suggestions, misspelledTerm);
    }
    
    public List<SearchResultDTO> fuzzySearch(String searchTerm, float similarityThreshold) {
        return searchRepository.fuzzySearch(searchTerm, similarityThreshold);
    }
}
