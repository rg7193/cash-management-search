package com.cashmanagement.search.controller;

import com.cashmanagement.search.dto.AutocompleteResponse;
import com.cashmanagement.search.dto.SearchRequest;
import com.cashmanagement.search.dto.SearchResultDTO;
import com.cashmanagement.search.dto.SpellingCorrectionResponse;
import com.cashmanagement.search.service.SearchService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/search")
@RequiredArgsConstructor
@Tag(name = "Search API", description = "API for searching cash management data")
@CrossOrigin(origins = "*")
public class SearchController {

    private final SearchService searchService;

    @PostMapping
    @Operation(summary = "Search across all entities", description = "Performs full-text search across payments, deposits, and loans")
    public ResponseEntity<Page<SearchResultDTO>> search(@RequestBody SearchRequest request) {
        return ResponseEntity.ok(searchService.search(request));
    }

    @GetMapping("/autocomplete")
    @Operation(summary = "Get autocomplete suggestions", description = "Returns autocomplete suggestions based on the provided prefix")
    public ResponseEntity<AutocompleteResponse> autocomplete(
            @RequestParam String prefix,
            @RequestParam(defaultValue = "10") int limit) {
        return ResponseEntity.ok(searchService.getAutocompleteSuggestions(prefix, limit));
    }

    @GetMapping("/spelling")
    @Operation(summary = "Get spelling suggestions", description = "Returns spelling correction suggestions for potentially misspelled terms")
    public ResponseEntity<SpellingCorrectionResponse> spellingSuggestions(
            @RequestParam String term,
            @RequestParam(defaultValue = "5") int limit) {
        return ResponseEntity.ok(searchService.getSpellingSuggestions(term, limit));
    }

    @GetMapping("/fuzzy")
    @Operation(summary = "Perform fuzzy search", description = "Performs fuzzy search using trigram similarity")
    public ResponseEntity<List<SearchResultDTO>> fuzzySearch(
            @RequestParam String query,
            @RequestParam(defaultValue = "0.3") float threshold) {
        return ResponseEntity.ok(searchService.fuzzySearch(query, threshold));
    }
}
