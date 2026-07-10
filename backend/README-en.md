# Money Transfer App Backend

## Overview

This backend provides the server-side logic for the money transfer application. It is built with Ruby on Rails and uses SQLite database to manage data. The API supports account management, balance inquiry, balance updates, and money transfer processing.

## Required Versions

- **Ruby**: 3.2.2
- **Rails**: 7.1.2

## Project Structure

```
backend/
├── app/
│   ├── controllers/           # HTTP controllers
│   │   └── api/
│   │       ├── accounts_controller.rb   # Account-related controller
│   │       └── balances_controller.rb   # Balance-related controller
│   ├── models/                # Data models
│   │   ├── account.rb         # Account model
│   │   ├── balance.rb         # Balance model
│   │   └── transaction_log.rb # TransactionLog model
│   ├── services/              # Business logic
│   │   ├── money_transfer_service.rb    # Money transfer service
│   │   └── transaction_log_service.rb   # Transaction log service
│   └── validators/            # Validators
│       └── balance_validator.rb         # Balance validator
├── config/
│   └── routes.rb              # Routing configuration
├── db/
│   ├── migrate/               # Migration files
│   └── seeds.rb               # Seed data
├── spec/                      # Test code
├── Dockerfile                 # Docker configuration
├── Gemfile                    # Gem dependencies
└── README.md                  # This file
```

## More Information

You can learn more details in the [Ruby on Rails documentation](https://guides.rubyonrails.org/v7.1/index.html).
