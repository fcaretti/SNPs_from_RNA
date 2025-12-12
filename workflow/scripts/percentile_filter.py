#!/usr/bin/env python3
"""
Percentile-Based VCF Filtering

WARNING: This approach is NOT RECOMMENDED for RNA-seq variant calling!
Percentile-based filtering does not account for biological significance and
may retain low-quality variants or filter out true positives.

Recommended approach: Use caller-specific or default filtering parameters
based on established quality thresholds (QUAL, DP, GQ, etc.).

This script is provided as a fallback option only.
"""

import sys
import logging
from pathlib import Path
from cyvcf2 import VCF, Writer
import numpy as np


def setup_logging(log_file):
    """Configure logging to both file and stderr."""
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(levelname)s - %(message)s',
        handlers=[
            logging.FileHandler(log_file),
            logging.StreamHandler(sys.stderr)
        ]
    )


def collect_metrics(vcf_path, caller):
    """
    First pass: Collect QUAL and DP values from all variants.

    Args:
        vcf_path: Path to input VCF file
        caller: Caller name (for determining DP field location)

    Returns:
        tuple: (list of QUAL values, list of DP values)
    """
    logging.info(f"First pass: Collecting QUAL and DP metrics from {vcf_path}")

    vcf = VCF(vcf_path)
    qual_values = []
    dp_values = []

    for variant in vcf:
        # Collect QUAL
        if variant.QUAL is not None and not np.isnan(variant.QUAL):
            qual_values.append(variant.QUAL)

        # Collect DP - try INFO field first, then FORMAT field
        dp = None
        if 'DP' in variant.INFO:
            dp = variant.INFO.get('DP')
        elif hasattr(variant, 'format') and 'DP' in variant.format:
            # For FORMAT DP, take the maximum across samples
            dp_array = variant.format('DP')
            if dp_array is not None and len(dp_array) > 0:
                dp = np.max(dp_array)

        if dp is not None and not np.isnan(dp):
            dp_values.append(dp)

    vcf.close()

    logging.info(f"Collected {len(qual_values)} QUAL values and {len(dp_values)} DP values")
    return qual_values, dp_values


def calculate_thresholds(qual_values, dp_values, qual_percentile, dp_percentile):
    """
    Calculate percentile thresholds.

    Args:
        qual_values: List of QUAL scores
        dp_values: List of DP values
        qual_percentile: Percentile for QUAL (variants below this are filtered)
        dp_percentile: Percentile for DP (variants below this are filtered)

    Returns:
        tuple: (QUAL threshold, DP threshold)
    """
    qual_threshold = None
    dp_threshold = None

    if qual_values:
        qual_threshold = np.percentile(qual_values, qual_percentile)
        logging.info(f"QUAL {qual_percentile}th percentile: {qual_threshold:.2f}")
    else:
        logging.warning("No QUAL values found in VCF")

    if dp_values:
        dp_threshold = np.percentile(dp_values, dp_percentile)
        logging.info(f"DP {dp_percentile}th percentile: {dp_threshold:.2f}")
    else:
        logging.warning("No DP values found in VCF")

    return qual_threshold, dp_threshold


def filter_vcf(input_vcf, output_vcf, qual_threshold, dp_threshold, caller):
    """
    Second pass: Filter variants based on calculated thresholds.

    Args:
        input_vcf: Path to input VCF
        output_vcf: Path to output VCF
        qual_threshold: Minimum QUAL score
        dp_threshold: Minimum DP value
        caller: Caller name (for determining DP field location)
    """
    logging.info(f"Second pass: Filtering variants")
    logging.info(f"Thresholds: QUAL >= {qual_threshold}, DP >= {dp_threshold}")

    vcf = VCF(input_vcf)
    writer = Writer(output_vcf, vcf)

    total_variants = 0
    passed_variants = 0

    for variant in vcf:
        total_variants += 1

        # Check QUAL threshold
        qual_pass = True
        if qual_threshold is not None:
            if variant.QUAL is None or np.isnan(variant.QUAL) or variant.QUAL < qual_threshold:
                qual_pass = False

        # Check DP threshold
        dp_pass = True
        if dp_threshold is not None:
            dp = None
            if 'DP' in variant.INFO:
                dp = variant.INFO.get('DP')
            elif hasattr(variant, 'format') and 'DP' in variant.format:
                dp_array = variant.format('DP')
                if dp_array is not None and len(dp_array) > 0:
                    dp = np.max(dp_array)

            if dp is None or np.isnan(dp) or dp < dp_threshold:
                dp_pass = False

        # Write variant if it passes both filters
        if qual_pass and dp_pass:
            writer.write_record(variant)
            passed_variants += 1

    vcf.close()
    writer.close()

    filtered_count = total_variants - passed_variants
    filter_rate = (filtered_count / total_variants * 100) if total_variants > 0 else 0

    logging.info(f"Total variants: {total_variants}")
    logging.info(f"Passed variants: {passed_variants}")
    logging.info(f"Filtered variants: {filtered_count} ({filter_rate:.1f}%)")


def main():
    """Main entry point."""
    if len(sys.argv) != 7:
        print("Usage: percentile_filter.py <input_vcf> <output_vcf> <caller> <qual_percentile> <dp_percentile> <log_file>")
        sys.exit(1)

    input_vcf = sys.argv[1]
    output_vcf = sys.argv[2]
    caller = sys.argv[3]
    qual_percentile = float(sys.argv[4])
    dp_percentile = float(sys.argv[5])
    log_file = sys.argv[6]

    # Setup logging
    setup_logging(log_file)

    # Log strong warnings
    logging.warning("=" * 80)
    logging.warning("PERCENTILE-BASED FILTERING IS NOT RECOMMENDED FOR RNA-SEQ!")
    logging.warning("This approach does not account for biological significance.")
    logging.warning("Please consider using caller-specific filtering parameters instead.")
    logging.warning("=" * 80)

    logging.info(f"Input VCF: {input_vcf}")
    logging.info(f"Output VCF: {output_vcf}")
    logging.info(f"Caller: {caller}")
    logging.info(f"QUAL percentile threshold: {qual_percentile}")
    logging.info(f"DP percentile threshold: {dp_percentile}")

    # Validate input file exists
    if not Path(input_vcf).exists():
        logging.error(f"Input VCF file not found: {input_vcf}")
        sys.exit(1)

    # First pass: collect metrics
    qual_values, dp_values = collect_metrics(input_vcf, caller)

    if not qual_values and not dp_values:
        logging.warning("No quality metrics found in VCF. Passing through without filtering.")
        # Just copy the input to output
        import shutil
        shutil.copy(input_vcf, output_vcf)
        sys.exit(0)

    # Calculate thresholds
    qual_threshold, dp_threshold = calculate_thresholds(
        qual_values, dp_values, qual_percentile, dp_percentile
    )

    # Second pass: filter
    filter_vcf(input_vcf, output_vcf, qual_threshold, dp_threshold, caller)

    logging.info("Percentile-based filtering complete")
    logging.warning("Remember: Consider using biological thresholds instead of percentiles!")


if __name__ == "__main__":
    main()
