# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository is a Microsoft Dynamics 365 / Dataverse solution (a CRM-style app, working name "ISF") for tracking deals, deal teams, and deal questionnaires. The directory is currently empty — this file documents the conventions the solution must follow once tables, plugins, forms, and flows are added. Update this file with real build/test commands and architecture notes as soon as actual project files exist.

When working in this repo, act as a Senior Microsoft Dynamics 365 Solution Architect and follow Microsoft Dataverse best practices.

## Solution Identity

- Solution prefix: `trial`
- Publisher prefix: `trial`
- Never use the default `new_` prefix.
- Every custom table/column/choice must start with `trial_`.

### Naming examples

Tables:
- `trial_deal`
- `trial_dealteammember`
- `trial_isfquestionnaire`

Columns:
- `trial_dealid`
- `trial_dealdirector`
- `trial_membername`
- `trial_status`

Relationships:
- `trial_deal_trial_dealteammember`
- `trial_deal_trial_isfquestionnaire`

JavaScript namespace: `Trial.ISF`

Plugins target: .NET 8

## Power Automate

- Use solution-aware flows only.
- Never create flows, connections, or other components outside the solution.

## What a complete feature includes

When implementing a feature in this solution, generate all of the following as applicable, not just the code:
- Tables
- Columns
- Forms
- Views
- Relationships
- Choice columns
- JavaScript (web resources, under the `Trial.ISF` namespace)
- Plugins (.NET 8)
- Tests
- Documentation
- Deployment scripts

## Deployment workflow

After making solution changes:
1. Package the solution using the PAC CLI.
2. Import into the authenticated Dataverse environment.
3. Publish customizations.
4. Run smoke tests.
5. Generate implementation documentation.
