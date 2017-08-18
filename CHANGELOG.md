# 0.5.0 (2017-08-18)
- Add new API (`find_easy_ab_variant`) to retrieve specified user's variant

# 0.4.2 (2017-08-18)
- Specify URL parameter to assign variant works for all user instead of admin only in development environment now. In production and test, admin is still required for assigning variant by URL paramenter.

# 0.4.1 (2017-08-18)
- Provide helper to assign variant in rspec

# 0.4.0 (2017-08-16)
- You can specify user in `ab_test()` This useful when requests do not contain current_user. A well-known example is controllers which handle payment results by listening requests from 3rd party payment gateway.

# 0.3.0 (2017-08-16)
- Supports scope in config to define whether a user can join an experiment or not.

# 0.2.0 (2017-08-15)
- **API change**: If all rules failed, `ab_test` returns nil, instead of the first variant.

# 0.1.0
- Support winner

# 0.0.3
- Add new API `all_participated_experiments` to list current user's all participated experiments

# 0.0.1
- The first version :)