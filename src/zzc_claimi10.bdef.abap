projection implementation in class ZZBP_C_CLAIMI10 unique;
strict ( 2 );
extensible;
use draft;
use side effects;
define behavior for ZZC_CLAIMI10 alias Claim
extensible
use etag
{
  use create;
  use update;
  use delete;

  use action Edit;
  use action Activate;
  use action Discard;
  use action Resume;
  use action Prepare;
  use action Validate;
  use action Approve;
  use action Reject;

}
