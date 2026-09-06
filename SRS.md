# 1Fi Marketplace — Product Requirements

The product provides a polished mobile Shop shell with Top Brands, Nearby Stores, and a fully implemented Marketplace. The first two sections are intentionally blank. Marketplace users can asynchronously load and search products by name or category, view product pricing, details and variants, load eligible EMI plans, select exactly one plan, and reach a confirmation that makes no payment claim.

Every asynchronous surface supports loading and recoverable failure. Search supports a no-results state. Variant changes reset dependent EMI selection. The primary action remains disabled until a plan is chosen. Plan disclosures include tenure, monthly installment, total payable, interest or zero-cost status, and processing fee.

The experience targets narrow and large phone layouts with scrollable content, 44px-or-larger controls, readable wrapping, assistive labels, non-color selection cues, and standard back behavior. Catalog and finance fixtures live behind typed asynchronous service interfaces. Real APIs, accounts, credit checks, payments, fulfillment, nearby-store discovery, and production brand assets are outside scope.

Acceptance requires all three Shop sections, service-backed catalog/search, variant-aware details, exclusive EMI selection, correct confirmation, demonstrable loading/error/empty states, responsive layouts, and passing analysis/tests.
