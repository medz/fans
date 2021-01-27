import { Args, GraphQLISODateTime, Mutation, Resolver } from '@nestjs/graphql';
import { HasTokenExpiredType } from 'src/authorization-token/enums';
import { Authorization } from 'src/authorization.decorator';
import { USER_NOT_SET_PHONE } from 'src/constants';
import { Context } from 'src/context';
import { SecuritySmsService } from './security-sms.service';

@Resolver()
export class SecuritySmsResolver {
  constructor(
    private readonly securitySmsService: SecuritySmsService,
    private readonly context: Context,
  ) {}

  @Mutation(() => GraphQLISODateTime)
  async createSecurity(
    @Args({
      name: 'phone',
      description: 'Need send code phone number',
      type: () => String,
    })
    phone: string,
  ) {
    const { expiredAt } = await this.securitySmsService.send(phone);
    return expiredAt;
  }

  @Mutation(() => GraphQLISODateTime)
  @Authorization({ hasAuthorization: true, type: HasTokenExpiredType.AUTH })
  async createViewerSecurity() {
    const { phone } = this.context.user || {};
    if (!phone) {
      throw new Error(USER_NOT_SET_PHONE);
    }

    return await this.createSecurity(phone);
  }
}