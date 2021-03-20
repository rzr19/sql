create procedure UpdateTContractLessorID
  @ContractId bigint,
  @NewLessorId bigint

as
if exists (select distinct partnerid from tpartner where partnerid = @NewLessorId)
begin
	if exists (select distinct contractid from tcontract where contractid = @ContractId)
	begin
	    declare @NewLessorCompanyCode nvarchar(255)
		set @NewLessorCompanyCode = ( select COMPANYCODE from TPARTNER where partnerid = @NewLessorId )

		update tcontract set lessorid = @NewLessorId, lessorcompanycode = @NewLessorCompanyCode
		where contractid = @ContractId -- and contractnumber = @ContractNumber and lesseeid = @LesseeId

		update TLesseeLessorDependency set lessorid = @NewLessorId, lessorcompanycode = @NewLessorCompanyCode
		where contractid = @ContractId -- and lesseeid = @Lesseeid

		declare @now datetime2 = sysdatetime();
		PRINT 'Updated information for ContractId=' + CONVERT(VARCHAR(10), @ContractId) 
			+ ' with NewLessorId=' + CONVERT(VARCHAR(10), @NewLessorId)
			+ ' and with NewLessorCompanyCode=' + CONVERT(VARCHAR(10), @NewLessorCompanyCode)
			+ ' at system time=' + convert(char(10), @now, 121 )
	end
	else
		print 'ContractId=' + @ContractId + ' does not exist in table TCONTRACT.'
end
else 
	print 'LessorId=' + @NewLessorId + ' does not exist in table TPARTNER.'
go
