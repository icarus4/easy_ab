## 0.8.1 (2019-01-08)
- Add more description in initializer

## 0.8.0 (2019-01-08)
- Provide a solution so you are no longer to restart rails server to apply any definition changes of experiments in development mode.

## 0.7.0 (2017-11-21)
- Set domain of cookie to :all to support cross-subdomain experiment.

## 0.6.2 (2017-09-01)
- [BF] Calling ab_test multiple times with different experiment name in one request may cause unwanted result if the definitions of experiments contain scope or rules.

## 0.6.1 (2017-08-31)
- Include EasyAb::RSpec with mailer type. Now you can use `#assign_variant!` in mailer spec

## 0.6.0 (2017-08-25)
- Add new API (`assign_variant!`)
- Rename spec helper #assign_variant to #assign_variant! and return instance of EasyAb::Grouping instead of true/false

## 0.5.1 (2017-08-25)
- Add new API (`easy_ab_test`) for internal use.

## 0.5.0 (2017-08-18)
- Add new API (`find_easy_ab_variant`) to retrieve specified user's variant

## 0.4.2 (2017-08-18)
- Specify URL parameter to assign variant works for all user instead of admin only in development environment now. In production and test, admin is still required for assigning variant by URL paramenter.

## 0.4.1 (2017-08-18)
- Provide helper to assign variant in rspec

## 0.4.0 (2017-08-16)
- You can specify user in `ab_test()` This useful when requests do not contain current_user. A well-known example is controllers which handle payment results by listening requests from 3rd party payment gateway.

## 0.3.0 (2017-08-16)
- Supports scope in config to define whether a user can join an experiment or not.

## 0.2.0 (2017-08-15)
- **API change**: If all rules failed, `ab_test` returns nil, instead of the first variant.

## 0.1.0
- Support winner

## 0.0.3
- Add new API `all_participated_experiments` to list current user's all participated experiments

## 0.0.1
- The first version :)