# DEC-003: Every app is a left-menu CRUD admin app, structured as Governance, The machine, Across the machine

Oct 19, 2026 · Decided by the maintainer

**Decision.** Every app uses a CRUD admin layout with the main menu on the left. The menu has three bands: Governance at the top; The machine, the phases in order (lead generation, lead activation, product delivery); and Across the machine, the functions that run through every phase (risk, compliance, finance, people, technology). Every job names its menu home.

**Why.** Consistency across all entities' apps, so a director or the CRCO finds the same thing in the same place everywhere, and a menu that reads like the business: rules first, then the customer's journey, then what supports every step. The target-architecture docs kept producing pages with menus across the top.

**How the standard changed.** UIX-3 is amended in place rather than retired, and JOB-5 is added. Plumbline's own rule says changing a clause's requirement is a major version. This is a minor version (v0.4.0) by exception: UIX-3 was hours old, and no app or board had adopted v0.3.0. Once any app pins a version, this exception is not available again.
