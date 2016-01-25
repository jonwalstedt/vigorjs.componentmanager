define(function (require) {

  'use strict';

  var _ = require('underscore'),
      AccountTypes = require('app/AccountTypes'),
      MathUtil = require('utils/MathUtil'),
      UsersRepository = require('repositories/users/UsersRepository');

  return function (arcs) {
    var user = UsersRepository.getLoggedInUser(),
        limit = AccountTypes[user.account].bytesLimit,
        formattedLimit = MathUtil.formatBytes(limit, 2),

        bytesUsedTotal = arcs[0].bytesUsed,
        formattedTotal = MathUtil.formatBytes(bytesUsedTotal, 2),

        bytesUsed = arcs[1].bytesUsed,
        formattedUsed = MathUtil.formatBytes(bytesUsed, 2),

        usedPercentage = +((bytesUsed / limit) * 100).toFixed(2),
        usedTargetAngle = MathUtil.degreesToRadians(MathUtil.percentToDegrees(usedPercentage)),
        usedTotalPercentage = +((bytesUsedTotal / limit) * 100).toFixed(2),
        usedTotalTargetAngle = MathUtil.degreesToRadians(MathUtil.percentToDegrees(usedTotalPercentage));

    _.extend(arcs[0], {
      limit: formattedLimit.value,
      limitSuffix: formattedLimit.suffix,
      usedSuffix: formattedTotal.suffix,
      targetPercent: usedTotalPercentage,
      targetUsed: formattedTotal.value,
      targetAngle: usedTotalTargetAngle
    });

    _.extend(arcs[1], {
      limit: formattedLimit.value,
      limitSuffix: formattedLimit.suffix,
      usedSuffix: formattedUsed.suffix,
      targetPercent: usedPercentage,
      targetUsed: formattedUsed.value,
      targetAngle: usedTargetAngle
    });

    return arcs;
  }
});
